import SwiftUI
import SharedKit

public struct CelebrationView: View {
    public enum WinType {
        case money(cents: Int)
        case task(title: String)
    }
    
    let winType: WinType
    let onDismiss: () -> Void
    
    @State private var particles: [Particle] = []
    
    public init(winType: WinType, onDismiss: @escaping () -> Void) {
        self.winType = winType
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            // Confetti
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(x: particle.x, y: particle.y, width: particle.size, height: particle.size)
                    context.fill(Path(ellipseIn: rect), with: .color(particle.color))
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(themeColor)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .onAppear {
            triggerHaptics()
            createParticles()
            animateParticles()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
        .onTapGesture {
            onDismiss()
        }
    }
    
    private var title: String {
        switch winType {
        case .money(let cents):
            return "+\(cents.formattedCents(currencyCode: "USD")) ADHD Tax Refunded"
        case .task:
            return "+1 Task Unfrozen"
        }
    }
    
    private var subtitle: String {
        switch winType {
        case .money:
            return "That's real money back."
        case .task:
            return "Your brain works. It just needed a parachute."
        }
    }
    
    private var themeColor: Color {
        switch winType {
        case .money:
            return Theme.money
        case .task:
            return Theme.frozen
        }
    }
    
    private func triggerHaptics() {
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        heavy.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
    }
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: Double
        var y: Double
        var size: Double
        var color: Color
        var velocityX: Double
        var velocityY: Double
    }
    
    private func createParticles() {
        let colors: [Color] = [Theme.money, Theme.frozen, Theme.accent, .white, .yellow, .pink]
        var newParticles: [Particle] = []
        for _ in 0..<100 {
            newParticles.append(Particle(
                x: Double.random(in: 0...400),
                y: Double.random(in: -100...0),
                size: Double.random(in: 5...15),
                color: colors.randomElement() ?? .white,
                velocityX: Double.random(in: -3...3),
                velocityY: Double.random(in: 2...8)
            ))
        }
        particles = newParticles
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            withAnimation(.linear(duration: 1/60)) {
                for i in particles.indices {
                    particles[i].x += particles[i].velocityX
                    particles[i].y += particles[i].velocityY
                    particles[i].velocityY += 0.1 // gravity
                }
            }
            if particles.allSatisfy({ $0.y > 1000 }) {
                timer.invalidate()
            }
        }
    }
}
