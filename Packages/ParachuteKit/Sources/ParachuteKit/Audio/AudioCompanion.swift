import AVFoundation
#if canImport(CoreAudio)
import CoreAudio // UnsafeMutableAudioBufferListPointer lives in the CoreAudio overlay; AVFAudio doesn't re-export it.
#endif
import Observation

/// B9: reads each step aloud (AVSpeechSynthesizer) and plays a soft procedural ambient bed (AVAudioEngine;
/// generated brown noise with a slow swell, so there's no licensed audio). Pro feature (B10).
/// Call `stop()` when the player closes.
@MainActor
@Observable
public final class AudioCompanion {
    public private(set) var isVoiceOn = false
    public private(set) var isAmbientOn = false

    private let synthesizer = AVSpeechSynthesizer()
    private var engine: AVAudioEngine?
    private var fadeTask: Task<Void, Never>?
    private static let ambientVolume: Float = 0.35

    public init() {}

    public func setVoice(_ on: Bool) {
        isVoiceOn = on
        if on { activateSession() } else { synthesizer.stopSpeaking(at: .immediate) }
    }

    public func setAmbient(_ on: Bool) {
        isAmbientOn = on
        on ? startAmbient() : fadeOutAmbient()
    }

    public func speak(_ text: String) {
        guard isVoiceOn else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        synthesizer.speak(utterance)
    }

    /// Stops speech and ambient sound and releases the audio session.
    public func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        fadeTask?.cancel()
        engine?.stop()
        engine = nil
        isVoiceOn = false
        isAmbientOn = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Ambient

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func startAmbient() {
        activateSession()
        if engine == nil {
            let engine = AVAudioEngine()
            let format = engine.outputNode.inputFormat(forBus: 0)
            let node = Self.makeNoiseNode(sampleRate: format.sampleRate)
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: AVAudioFormat(standardFormatWithSampleRate: format.sampleRate, channels: 1))
            engine.mainMixerNode.outputVolume = 0
            self.engine = engine
        }
        guard let engine else { return }
        if !engine.isRunning {
            do { try engine.start() } catch { self.engine = nil; isAmbientOn = false; return }
        }
        fade(to: Self.ambientVolume, seconds: 2)
    }

    private func fadeOutAmbient() {
        fade(to: 0, seconds: 1) { [weak self] in
            self?.engine?.stop()
            self?.engine = nil
        }
    }

    private func fade(to target: Float, seconds: Double, then done: (@MainActor () -> Void)? = nil) {
        fadeTask?.cancel()
        fadeTask = Task { [weak self] in
            let steps = 20
            guard let start = self?.engine?.mainMixerNode.outputVolume else { return }
            for i in 1...steps {
                try? await Task.sleep(for: .seconds(seconds / Double(steps)))
                if Task.isCancelled { return }
                self?.engine?.mainMixerNode.outputVolume = start + (target - start) * Float(i) / Float(steps)
            }
            done?()
        }
    }

    /// Built outside the main actor: the render block runs on the real-time audio thread.
    nonisolated private static func makeNoiseNode(sampleRate: Double) -> AVAudioSourceNode {
        let generator = BrownNoise(sampleRate: Float(sampleRate))
        return AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let sample = generator.next()
                for buffer in buffers {
                    buffer.mData?.assumingMemoryBound(to: Float.self)[frame] = sample
                }
            }
            return noErr
        }
    }
}

/// Integrated white noise (brown noise: soft, like distant rain) with a slow ~10-second swell.
/// Only touched from the audio render thread.
private final class BrownNoise: @unchecked Sendable {
    private var last: Float = 0
    private var phase: Float = 0
    private var seed: UInt32 = 0x9E37_79B9
    private let phaseStep: Float

    init(sampleRate: Float) {
        phaseStep = 2 * .pi * 0.1 / sampleRate
    }

    func next() -> Float {
        // xorshift: no locks or allocation on the audio thread.
        seed ^= seed << 13; seed ^= seed >> 17; seed ^= seed << 5
        let white = Float(seed) / Float(UInt32.max) * 2 - 1
        last = (last + white * 0.02) * 0.998
        phase += phaseStep
        if phase > 2 * .pi { phase -= 2 * .pi }
        let swell = 0.75 + 0.25 * sin(phase)
        return max(-1, min(1, last * 3 * swell))
    }
}
