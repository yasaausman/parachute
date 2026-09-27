import Foundation
import AVFoundation
import Observation

@Observable
public final class AudioCompanion {
    public var isVoiceEnabled: Bool = true
    public var isAmbientEnabled: Bool = true
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    
    public init() {}
    
    deinit {
        stop()
    }
    
    public func start() {
        setupAudioEngine()
        if isAmbientEnabled {
            engine?.mainMixerNode.outputVolume = 0.0
            try? engine?.start()
            
            // Fade in
            var vol: Float = 0.0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                vol += 0.01
                if vol >= 0.1 {
                    self?.engine?.mainMixerNode.outputVolume = 0.1
                    timer.invalidate()
                } else {
                    self?.engine?.mainMixerNode.outputVolume = vol
                }
            }
        }
    }
    
    public func stop() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        // Fade out
        guard let engine = engine, engine.isRunning else { return }
        
        var vol: Float = engine.mainMixerNode.outputVolume
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            vol -= 0.01
            if vol <= 0.0 {
                self?.engine?.mainMixerNode.outputVolume = 0.0
                self?.engine?.stop()
                timer.invalidate()
            } else {
                self?.engine?.mainMixerNode.outputVolume = vol
            }
        }
    }
    
    public func speakStep(_ text: String) {
        guard isVoiceEnabled else { return }
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // slightly slow
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Use default system voice
        if let voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode()) {
            utterance.voice = voice
        }
        
        speechSynthesizer.speak(utterance)
    }
    
    private func setupAudioEngine() {
        if engine == nil {
            engine = AVAudioEngine()
        }
        guard let engine = engine else { return }
        
        let format = engine.outputNode.inputFormat(forBus: 0)
        let sampleRate = format.sampleRate
        
        var phase: Float = 0.0
        let frequency: Float = 220.0
        let amplitude: Float = 0.2
        var modPhase: Float = 0.0
        let modFrequency: Float = 0.1 // Gentle modulation
        
        if sourceNode == nil {
            sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
                let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for frame in 0..<Int(frameCount) {
                    // Modulate amplitude slightly
                    let mod = sin(modPhase)
                    modPhase += 2.0 * Float.pi * modFrequency / Float(sampleRate)
                    if modPhase > 2.0 * Float.pi { modPhase -= 2.0 * Float.pi }
                    
                    let currentAmp = amplitude + (mod * 0.05)
                    
                    let value = sin(phase) * currentAmp
                    phase += 2.0 * Float.pi * frequency / Float(sampleRate)
                    if phase > 2.0 * Float.pi { phase -= 2.0 * Float.pi }
                    
                    for buffer in ablPointer {
                        let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                        buf[frame] = value
                    }
                }
                return noErr
            }
            
            if let sourceNode = sourceNode {
                engine.attach(sourceNode)
                engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
            }
        }
    }
}
