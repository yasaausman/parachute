import Foundation
import SharedKit

/// A4: when the final-day alarm rings and what it says. Pure, so it's fully testable.
public enum DeadlineAlarmPlanner {
    /// The alarm rings at 9:00 on the last day to act (reminders come at 10:00 on earlier days).
    public static let alarmHour = 9
    /// Stop brings it back after this long, until a decision is recorded (CLAUDE.md rule 2).
    public static let rearmDelay: TimeInterval = 30 * 60
    /// Under debug time travel the chain re-rings every minute.
    public static let timeTravelRearmDelay: TimeInterval = 60

    /// 9:00 on the last day to act (the day before the charge for Apple-billed items).
    /// Added late on that same day? Ring in a minute instead. Otherwise nil once the day is over.
    public static func moneyFireDate(chargeDate: Date, billedByApple: Bool, now: Date, calendar: Calendar = .current) -> Date? {
        let actDay = calendar.startOfDay(for: DeadlineMath.cancelBy(due: chargeDate, billedByApple: billedByApple))
        guard let planned = calendar.date(bySettingHour: alarmHour, minute: 0, second: 0, of: actDay),
              let endOfActDay = calendar.date(byAdding: .day, value: 1, to: actDay)
        else { return nil }
        if planned > now { return planned }
        if now < endOfActDay { return now.addingTimeInterval(60) }
        return nil
    }

    /// Short enough for the Lock Screen banner, where it's the whole message.
    public static func moneyTitle(serviceName: String, amountCents: Int, currencyCode: String, billedByApple: Bool) -> String {
        let amount = amountCents.formattedCents(currencyCode: currencyCode)
        return billedByApple
            ? "Cancel \(serviceName) today · \(amount) tomorrow"
            : "\(serviceName) charges \(amount) today"
    }

    public static func rearmDelay(timeTravel: Bool) -> TimeInterval {
        timeTravel ? timeTravelRearmDelay : rearmDelay
    }

    /// Time travel squeezes the wait (1 day → 1 minute) but never below 10 s.
    public static func effectiveFireDate(_ planned: Date, now: Date, timeTravel: Bool) -> Date {
        guard timeTravel else { return planned }
        return now.addingTimeInterval(max(10, TimeTravel.compressedInterval(until: planned, now: now)))
    }
}
