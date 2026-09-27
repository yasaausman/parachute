import Foundation
import SharedKit

/// A value copy of a `CompletionRecord`, so the scoreboard math is testable without SwiftData.
public struct ScoreEntry: Sendable, Hashable {
    public var kind: CompletionKind
    public var amountCents: Int?
    public var date: Date

    public init(kind: CompletionKind, amountCents: Int?, date: Date) {
        self.kind = kind
        self.amountCents = amountCents
        self.date = date
    }
}

/// "ADHD Tax Refunded" numbers. Only cancellations add dollars; keeping a trial is a decision, not a refund;
/// snoozes never reach the ledger.
public enum ScoreMath {
    public static func refundedCents(_ entries: [ScoreEntry]) -> Int {
        entries.filter { $0.kind == .moneyCancelled }.compactMap(\.amountCents).reduce(0, +)
    }

    public static func tasksUnfrozen(_ entries: [ScoreEntry]) -> Int {
        entries.filter { $0.kind == .taskDone }.count
    }

    /// The longest run of consecutive days with at least one win. Always the best run, never "you lost your streak".
    public static func bestRun(_ entries: [ScoreEntry], calendar: Calendar = .current) -> Int {
        let days = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard var previous = days.first else { return 0 }
        var current = 1
        var best = 1
        for day in days.dropFirst() {
            let gap = calendar.dateComponents([.day], from: previous, to: day).day ?? 0
            current = gap == 1 ? current + 1 : 1
            best = max(best, current)
            previous = day
        }
        return best
    }

    /// Start-of-month keys, newest first, for the monthly list.
    public static func months(_ dates: [Date], calendar: Calendar = .current) -> [Date] {
        let starts = dates.compactMap { calendar.dateInterval(of: .month, for: $0)?.start }
        return Set(starts).sorted(by: >)
    }
}
