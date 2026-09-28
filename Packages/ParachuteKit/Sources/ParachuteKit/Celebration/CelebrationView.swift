import SharedKit
import SwiftUI

/// B7: confetti + haptics on every win. Dismisses itself after a few seconds or on tap.
/// Dev A can show it after a cancel: `CelebrationView(win: .money(cents: 1799)) { ... }`.
public struct CelebrationView: View {
    public enum Win: Sendable, Hashable {
        case money(cents: Int)
        case task(title: String)
    }

    let win: Win
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date.now
    @State private var confetti = Confetto.burst()
    @State private var dismissed = false
    @State private var cheered = false

    public init(win: Win, onDismiss: @escaping () -> Void) {
        self.win = win
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            if !reduceMotion {
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSince(start)
                    Canvas { context, size in
                        for piece in confetti {
                            let x = piece.x * size.width + piece.drift * t * 60
                            let y = -20 + piece.speed * t * 60 + 0.5 * 220 * t * t
                            guard y < size.height + 20 else { continue }
                            var shape = context
                            shape.translateBy(x: x, y: y)
                            shape.rotate(by: .degrees(piece.spin * t * 90))
                            shape.fill(Path(CGRect(x: -piece.size / 2, y: -piece.size / 4, width: piece.size, height: piece.size / 2)), with: .color(piece.color))
                        }
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }

            VStack(spacing: Theme.spacing) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(color)
                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.white)
                Text("Tap to continue")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, Theme.spacing)
            }
            .multilineTextAlignment(.center)
            .padding()
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: dismiss)
        .sensoryFeedback(.success, trigger: cheered)
        .task {
            cheered = true
            try? await Task.sleep(for: .seconds(4))
            dismiss()
        }
    }

    private func dismiss() {
        guard !dismissed else { return }
        dismissed = true
        onDismiss()
    }

    private var title: String {
        switch win {
        case .money(let cents): "+\(cents.formattedCents()) ADHD Tax Refunded"
        case .task: "+1 task unfrozen"
        }
    }

    private var subtitle: String {
        switch win {
        case .money: "That's real money back in your pocket."
        case .task(let title): "\(title). Done. Your brain works; it just needed a parachute."
        }
    }

    private var color: Color {
        switch win {
        case .money: Theme.money
        case .task: Theme.frozen
        }
    }
}

private struct Confetto {
    var x: Double
    var drift: Double
    var speed: Double
    var spin: Double
    var size: Double
    var color: Color

    static func burst() -> [Confetto] {
        let colors: [Color] = [Theme.money, Theme.frozen, Theme.accent, .white, .yellow, .pink]
        return (0..<90).map { _ in
            Confetto(
                x: .random(in: 0...1),
                drift: .random(in: -1.5...1.5),
                speed: .random(in: 1...5),
                spin: .random(in: -4...4),
                size: .random(in: 8...16),
                color: colors.randomElement() ?? .white
            )
        }
    }
}

#Preview {
    CelebrationView(win: .money(cents: 1799)) {}
}
