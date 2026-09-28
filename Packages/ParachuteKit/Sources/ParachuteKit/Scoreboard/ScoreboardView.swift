import SharedKit
import SwiftData
import SwiftUI

/// B6: the "ADHD Tax Refunded" scoreboard. Lives directly in a tab, so it owns its NavigationStack.
/// All numbers come from `ScoreMath` so the view and the tests agree.
public struct ScoreboardView: View {
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    shareButton
                }
            }
        }
        .tint(Palette.frozenInk)
    }

    // MARK: Share

    @ViewBuilder
    private var shareButton: some View {
        if !records.isEmpty {
            let current = entries
            let card = ShareCardView(
                refundedCents: ScoreMath.refundedCents(current),
                tasksUnfrozen: ScoreMath.tasksUnfrozen(current),
                bestRun: ScoreMath.bestRun(current)
            )
            if let image = card.image() {
                ShareLink(
                    item: image,
                    preview: SharePreview("My ADHD Tax Refunded", image: image)
                ) {
                    Label("Share my wins", systemImage: "square.and.arrow.up")
                }
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
    }

    // MARK: List

    private var scoreList: some View {
        List {
            Section {
                statCards
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            ForEach(months, id: \.self) { month in
                let monthRecords = recordsInMonth(month)
                Section {
                    ForEach(monthRecords) { record in
                        WinRow(record: record)
                    }
                } header: {
                    monthHeader(month: month, refundedCents: refundedCents(for: monthRecords))
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func monthHeader(month: Date, refundedCents: Int) -> some View {
        HStack {
            Text(month.formatted(.dateTime.month(.wide).year()))
            Spacer()
            if refundedCents > 0 {
                Text("+" + refundedCents.formattedCents())
                    .foregroundStyle(Palette.moneyInk)
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// One number carries the screen; the other two stats read as a sentence under it.
    private var statCards: some View {
        let current = entries
        let tasks = ScoreMath.tasksUnfrozen(current)
        let run = ScoreMath.bestRun(current)
        return VStack(alignment: .leading, spacing: 4) {
            Text("ADHD Tax Refunded")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(ScoreMath.refundedCents(current).formattedCents())
                .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(Palette.moneyInk)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("**\(tasks)** \(tasks == 1 ? "task" : "tasks") unfrozen · best run **\(run) \(run == 1 ? "day" : "days")**")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, Theme.spacing / 2)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Row

private struct WinRow: View {
    let record: CompletionRecord

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(.body)
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            trailing
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityText))
    }

    @ViewBuilder
    private var trailing: some View {
        switch record.kind {
        case .moneyCancelled:
            Text("+" + (record.amountCents ?? 0).formattedCents())
                .font(.body.weight(.semibold))
                .foregroundStyle(Palette.moneyInk)
        case .moneyKept:
            Text("Kept")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .taskDone:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Palette.frozenInk)
                .imageScale(.large)
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
