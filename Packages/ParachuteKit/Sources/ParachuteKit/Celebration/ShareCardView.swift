import SharedKit
import SwiftUI

/// B7: the "Share my wins" image. Always dark so it looks the same wherever it's posted.
public struct ShareCardView: View {
    let refundedCents: Int
    let tasksUnfrozen: Int
    let bestRun: Int

    public init(refundedCents: Int, tasksUnfrozen: Int, bestRun: Int) {
        self.refundedCents = refundedCents
        self.tasksUnfrozen = tasksUnfrozen
        self.bestRun = bestRun
    }

    public var body: some View {
        VStack(spacing: Theme.spacing) {
            Label("ADHD TAX REFUNDED", systemImage: "trophy.fill")
                .font(.headline.bold())
                .foregroundStyle(Theme.accent)

            Text(refundedCents.formattedCents())
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.money)

            HStack(spacing: 40) {
                stat("\(tasksUnfrozen)", tasksUnfrozen == 1 ? "task unfrozen" : "tasks unfrozen")
                stat("\(bestRun) \(bestRun == 1 ? "day" : "days")", "best run")
            }

            Text("Parachute · my brain works, it just needed a parachute")
                .font(.caption2)
                .foregroundStyle(.gray)
                .padding(.top, Theme.spacing)
        }
        .padding(32)
        .frame(width: 360)
        .background(Color.black, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.accent.opacity(0.3), lineWidth: 1))
        .environment(\.colorScheme, .dark)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack {
            Text(value).font(.title2.bold()).foregroundStyle(.white)
            Text(label).font(.caption).foregroundStyle(.gray)
        }
    }

    /// Renders at 3× for a crisp image in the share sheet.
    @MainActor
    public func image() -> Image? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3
        return renderer.uiImage.map { Image(uiImage: $0) }
    }
}

#Preview {
    ShareCardView(refundedCents: 21400, tasksUnfrozen: 12, bestRun: 5)
}
