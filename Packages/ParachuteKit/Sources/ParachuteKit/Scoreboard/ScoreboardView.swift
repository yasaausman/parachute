import SharedKit
import SwiftData
import SwiftUI

/// B6: the "ADHD Tax Refunded" scoreboard. Lives directly in a tab, so it owns its NavigationStack.
/// All numbers come from `ScoreMath` so the view and the tests agree.
public struct ScoreboardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var shareImage: Image?
    @Query(sort: \CompletionRecord.date, order: .reverse) private var records: [CompletionRecord]

    public init() {}

    // MARK: Derived values

    private var entries: [ScoreEntry] {
        records.map { ScoreEntry(kind: $0.kind, amountCents: $0.amountCents, date: $0.date) }
    }

    private var months: [Date] {
        ScoreMath.months(records.map(\.date))
    }

    private func recordsInMonth(_ month: Date) -> [CompletionRecord] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    private func refundedCents(for monthRecords: [CompletionRecord]) -> Int {
        ScoreMath.refundedCents(
            monthRecords.map { ScoreEntry(kind: $0.kind, amountCents: $0.amountCents, date: $0.date) }
        )
    }

    // MARK: Body

    public var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    scoreList
                }
            }
            .navigationTitle("Refunded")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    shareButton
                }
            }
        }
        .tint(Theme.accentText)
        // Render the share card only when its numbers change, not on every body update.
        .task(id: shareNumbers) {
            let n = shareNumbers
            shareImage = ShareCardView(refundedCents: n.refunded, tasksUnfrozen: n.tasks, bestRun: n.run).image()
        }
    }

    private var shareNumbers: ShareNumbers {
        let current = entries
        return ShareNumbers(
            refunded: ScoreMath.refundedCents(current),
            tasks: ScoreMath.tasksUnfrozen(current),
            run: ScoreMath.bestRun(current)
        )
    }

    private struct ShareNumbers: Hashable {
        var refunded: Int
        var tasks: Int
        var run: Int
    }

    // MARK: Share

    @ViewBuilder
    private var shareButton: some View {
        if !records.isEmpty, let image = shareImage {
            ShareLink(
                item: image,
                preview: SharePreview("My ADHD Tax Refunded", image: image)
            ) {
                Label("Share my wins", systemImage: "square.and.arrow.up")
            }
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Your wins land here", systemImage: "sparkles")
        } description: {
            Text("Nothing here yet, and that's okay. Your first win is one tap away.")
        }
        .untaxScreen()
    }

    // MARK: Receipt

    private var scoreList: some View {
        let current = entries
        let newestID = records.first?.persistentModelID
        return ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                receiptHeader
                ForEach(months, id: \.self) { month in
                    let monthRecords = recordsInMonth(month)
                    VStack(alignment: .leading, spacing: 10) {
                        monthHeader(month: month, refundedCents: refundedCents(for: monthRecords))
                        ForEach(monthRecords) { record in
                            WinRow(record: record)
                                .overlay(alignment: .trailing) {
                                    if record.persistentModelID == newestID, record.kind == .moneyCancelled {
                                        RefundedStamp().offset(x: -64, y: -2).accessibilityHidden(true)
                                    }
                                }
                        }
                    }
                }
                DashedDivider()
                totalBlock(current)
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.top, 28)
            .padding(.bottom, 40)
            .background(ReceiptShape(tooth: 10).fill(Theme.surface))
            .overlay(ReceiptShape(tooth: 10).stroke(Theme.hairline, lineWidth: 1))
            .padding(.horizontal, Theme.screenPadding)
            .padding(.vertical, Theme.spacing)
        }
        .untaxScreen()
    }

    private var receiptHeader: some View {
        VStack(spacing: 6) {
            Text("ADHD Tax Refunded")
                .font(Theme.display(.title2))
                .textCase(.uppercase)
                .tracking(1.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink)
            Text(Date.now.formatted(date: .abbreviated, time: .omitted).uppercased())
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.inkMuted)
            DashedDivider().padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func monthHeader(month: Date, refundedCents: Int) -> some View {
        // Stacked at accessibility sizes so the month name isn't squeezed into "Sep-tember".
        AnyLayout(dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout())) {
            Text(month.formatted(.dateTime.month(.wide).year()).uppercased())
            if !dynamicTypeSize.isAccessibilitySize { Spacer() }
            if refundedCents > 0 {
                Text("+" + refundedCents.formattedCents())
                    .foregroundStyle(Theme.moneyText)
            }
        }
        .font(.system(.caption, design: .monospaced, weight: .bold))
        .tracking(1)
        .foregroundStyle(Theme.inkMuted)
        .accessibilityElement(children: .combine)
    }

    /// TOTAL carries the screen; the other two stats read as receipt footer lines.
    private func totalBlock(_ current: [ScoreEntry]) -> some View {
        let tasks = ScoreMath.tasksUnfrozen(current)
        let run = ScoreMath.bestRun(current)
        return VStack(alignment: .leading, spacing: 8) {
            Text("TOTAL")
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .tracking(2)
                .foregroundStyle(Theme.ink)
            Text(ScoreMath.refundedCents(current).formattedCents())
                .font(Theme.number(.largeTitle).monospacedDigit())
                .foregroundStyle(Theme.moneyText)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
            DashedDivider()
            receiptLine("Tasks unfrozen", "\(tasks)")
            receiptLine("Best run", "\(run) \(run == 1 ? "day" : "days")")
            Text("Thank you for untaxing.")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.inkMuted)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
        .accessibilityElement(children: .combine)
    }

    private func receiptLine(_ name: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(name).foregroundStyle(Theme.inkMuted)
            Spacer(minLength: 8)
            Text(value).foregroundStyle(Theme.ink)
        }
        .font(.system(.subheadline, design: .monospaced).monospacedDigit())
    }
}

// MARK: - Receipt parts

private struct DashedDivider: View {
    var body: some View {
        Line()
            .stroke(Theme.inkMuted.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .frame(height: 1)
            .accessibilityHidden(true)
    }

    private struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return p
        }
    }
}

/// The rotated "REFUNDED" stamp on the newest money win.
private struct RefundedStamp: View {
    var body: some View {
        Text("REFUNDED")
            .font(.system(.caption, design: .monospaced, weight: .heavy))
            .tracking(1.5)
            .foregroundStyle(Theme.moneyText)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Theme.moneyText, lineWidth: 2))
            .rotationEffect(.degrees(-12))
            .opacity(0.85)
    }
}

// MARK: - Row

private struct WinRow: View {
    let record: CompletionRecord

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Stacked at accessibility sizes so amounts never wrap mid-number.
        // Plain branches, not AnyLayout: AnyLayout misreported heights for wrapped titles and rows overlapped.
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 6) { titleBlock; trailing }
            } else {
                HStack(alignment: .top, spacing: 8) {
                    titleBlock
                    Spacer(minLength: 8)
                    trailing
                }
            }
        }
        .font(.system(.subheadline, design: .monospaced))
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityText))
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(record.title)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(Theme.inkMuted)
        }
    }

    @ViewBuilder
    private var trailing: some View {
        switch record.kind {
        case .moneyCancelled:
            Text("+" + (record.amountCents ?? 0).formattedCents())
                .font(.system(.subheadline, design: .monospaced, weight: .bold).monospacedDigit())
                .foregroundStyle(Theme.moneyText)
        case .moneyKept:
            Text("KEPT")
                .foregroundStyle(Theme.inkMuted)
        case .taskDone:
            Text("DONE ✓")
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .foregroundStyle(Theme.frozenText)
        }
    }

    private var accessibilityText: String {
        let day = record.date.formatted(date: .abbreviated, time: .omitted)
        switch record.kind {
        case .moneyCancelled:
            return "\(record.title), refunded \((record.amountCents ?? 0).formattedCents()), \(day)"
        case .moneyKept:
            return "\(record.title), kept, \(day)"
        case .taskDone:
            return "\(record.title), done, \(day)"
        }
    }
}

// MARK: - Previews

#Preview("Empty") {
    ScoreboardView()
        .modelContainer(for: CompletionRecord.self, inMemory: true)
}

#Preview("With wins") {
    let container = try! ModelContainer(
        for: CompletionRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let now = Date.now
    let day: TimeInterval = 24 * 60 * 60
    container.mainContext.insert(CompletionRecord(kind: .moneyCancelled, title: "Cancelled Hulu", amountCents: 1799, date: now))
    container.mainContext.insert(CompletionRecord(kind: .taskDone, title: "Wrote history essay", date: now.addingTimeInterval(-day)))
    container.mainContext.insert(CompletionRecord(kind: .moneyKept, title: "Kept Spotify", date: now.addingTimeInterval(-2 * day)))
    container.mainContext.insert(CompletionRecord(kind: .moneyCancelled, title: "Cancelled Peacock", amountCents: 799, date: now.addingTimeInterval(-40 * day)))
    return ScoreboardView()
        .modelContainer(container)
}
