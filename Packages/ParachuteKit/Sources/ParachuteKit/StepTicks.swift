import SwiftUI

/// Progress as one tick per step, filled when done: "how far" at a glance instead of "Step 3 of 7".
/// Used on the player and on task rows.
struct StepTicks: View {
    let done: Int
    let total: Int
    var height: CGFloat = 6

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<max(total, 1), id: \.self) { i in
                Capsule()
                    .fill(i < done ? Palette.frozenInk : Color.secondary.opacity(0.4))
                    .frame(height: height)
            }
        }
        .animation(.easeOut(duration: 0.2), value: done)
        .accessibilityElement()
        .accessibilityLabel(done >= total ? "All \(total) steps done" : "Step \(done + 1) of \(total)")
    }
}

#Preview {
    VStack(spacing: 20) {
        StepTicks(done: 0, total: 5)
        StepTicks(done: 2, total: 7)
        StepTicks(done: 11, total: 12, height: 8)
    }
    .padding()
}
