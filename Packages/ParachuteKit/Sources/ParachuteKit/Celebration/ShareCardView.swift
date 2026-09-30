import SharedKit
import SwiftUI

/// B7: the "Share my wins" image: a light receipt on a coral field, the same wherever it's posted.
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
        VStack(alignment: .leading, spacing: 14) {
            Text("ADHD TAX REFUNDED")
                .font(.system(.title3, design: .rounded, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity)
            dashes
            line(tasksUnfrozen == 1 ? "Task unfrozen" : "Tasks unfrozen", "\(tasksUnfrozen)")
            line("Best run", "\(bestRun) \(bestRun == 1 ? "day" : "days")")
            dashes
            Text("TOTAL")
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .tracking(2)
                .foregroundStyle(Theme.ink)
            Text(refundedCents.formattedCents())
                .font(.system(size: 52, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.moneyText)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text("Untax · Get your ADHD tax back.")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.inkMuted)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 40)
        .background(ReceiptShape(tooth: 10).fill(Theme.surface))
        .padding(28)
        .frame(width: 360)
        .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .environment(\.colorScheme, .light)
    }

    private var dashes: some View {
        Rectangle()
            .fill(.clear)
            .frame(height: 1)
            .overlay(
                GeometryReader { g in
                    Path { p in
                        p.move(to: .zero)
                        p.addLine(to: CGPoint(x: g.size.width, y: 0))
                    }
                    .stroke(Theme.inkMuted.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            )
    }

    private func line(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name).foregroundStyle(Theme.inkMuted)
            Spacer()
            Text(value).foregroundStyle(Theme.ink)
        }
        .font(.system(.subheadline, design: .monospaced))
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
