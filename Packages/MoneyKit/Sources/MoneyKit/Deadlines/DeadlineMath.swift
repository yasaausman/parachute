import Foundation
import SharedKit

/// Pure date and money math for money deadlines. Everything takes `now` and a `Calendar`
/// so tests can pin both.
public enum DeadlineMath {
    /// Apple's subscribe sheet: "Cancel anytime in Settings > Apple Account at least a day
    /// before each renewal date." (seen on device, 2026-09-26)
    public static let appleCancelLeadTime: TimeInterval = 24 * 60 * 60

    /// The last moment cancelling still avoids the charge.
    public static func cancelBy(due: Date, billedByApple: Bool) -> Date {
        billedByApple ? due.addingTimeInterval(-appleCancelLeadTime) : due
    }

    /// Whole calendar days from `now` to `date`: 0 = today, 1 = tomorrow, -1 = yesterday.
    /// Counts midnights, so it's stable across daylight-saving changes.
    public static func calendarDays(from now: Date, to date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// "today", "tomorrow", "in 3 days". Past dates stay neutral (CLAUDE.md rule 10).
    public static func countdownText(days: Int) -> String {
        switch days {
        case ..<(-1): "was due \(-days) days ago"
        case -1: "was due yesterday"
        case 0: "today"
        case 1: "tomorrow"
        default: "in \(days) days"
        }
    }

    /// "Spotify · $6.99 in 3 days"
    public static func summary(serviceName: String, amountCents: Int, currencyCode: String, due: Date, now: Date, calendar: Calendar = .current) -> String {
        let days = calendarDays(from: now, to: due, calendar: calendar)
        return "\(serviceName) · \(amountCents.formattedCents(currencyCode: currencyCode)) \(countdownText(days: days))"
    }

    /// 17.99 → 1799. Rounds half-up to whole cents.
    public static func cents(from amount: Decimal) -> Int {
        var value = amount * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 0, .plain)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    /// Charges are tracked by day; the alarm/reminder time of day is chosen by the scheduler (A2/A4).
    public static func normalizedDueDate(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }
}

public extension MoneyDeadline {
    var cancelBy: Date {
        DeadlineMath.cancelBy(due: dueDate, billedByApple: billedByApple)
    }

    var isOpen: Bool {
        status == .tracking || status == .snoozed
    }
}
