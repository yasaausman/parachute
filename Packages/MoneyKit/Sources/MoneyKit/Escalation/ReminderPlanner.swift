import Foundation
import SharedKit

/// One local notification to schedule.
public struct PlannedReminder: Sendable, Hashable {
    /// "<itemID>.r3": stable, so rescheduling replaces instead of duplicating.
    public var id: String
    public var itemID: UUID
    public var fireDate: Date
    public var title: String
    public var body: String
}

/// A2: decides when reminders fire and what they say. Pure, so it's fully testable.
public enum ReminderPlanner {
    /// Money reminders land mid-morning, when there's time to act.
    public static let reminderHour = 10

    /// Money ladder: 3 days and 1 day before the last day to act, at 10:00.
    /// For Apple-billed items the last day to act is the day before the charge
    /// (Apple: "at least a day before each renewal date"). Past reminders are skipped.
    public static func moneyReminders(
        itemID: UUID,
        serviceName: String,
        amountCents: Int,
        currencyCode: String,
        chargeDate: Date,
        billedByApple: Bool,
        now: Date,
        calendar: Calendar = .current
    ) -> [PlannedReminder] {
        let amount = amountCents.formattedCents(currencyCode: currencyCode)
        let actDay = calendar.startOfDay(for: DeadlineMath.cancelBy(due: chargeDate, billedByApple: billedByApple))
        let chargeDay = chargeDate.formatted(.dateTime.month(.abbreviated).day())

        return [3, 1].compactMap { daysBefore -> PlannedReminder? in
            guard let day = calendar.date(byAdding: .day, value: -daysBefore, to: actDay),
                  let fire = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: day),
                  fire > now
            else { return nil }

            let title = DeadlineMath.summary(
                serviceName: serviceName, amountCents: amountCents, currencyCode: currencyCode,
                due: chargeDate, now: fire, calendar: calendar
            )
            let body: String
            switch (billedByApple, daysBefore) {
            case (false, 1): body = "\(amount) leaves your account tomorrow. Tap to decide: cancel, keep, or snooze."
            case (false, _): body = "Keep it or cancel it? Deciding now takes it off your mind."
            case (true, 1): body = "Billed by Apple, so cancel by tomorrow to skip the \(chargeDay) charge. Tap to decide."
            case (true, _): body = "Billed by Apple: cancel at least a day before \(chargeDay). Tap to decide."
            }
            return PlannedReminder(id: "\(itemID.uuidString).r\(daysBefore)", itemID: itemID, fireDate: fire, title: title, body: body)
        }
    }

    /// Task ladder (used by Dev B's task path, B5): a day before, an hour before, and at the due time.
    public static func taskReminders(itemID: UUID, title: String, due: Date, now: Date) -> [PlannedReminder] {
        let steps: [(suffix: String, offset: TimeInterval, body: String)] = [
            ("t1d", -24 * 60 * 60, "Due tomorrow. One tiny step now makes tomorrow easier."),
            ("t1h", -60 * 60, "Due in an hour. Tap and Parachute will give you one small step."),
            ("t0", 0, "It's due now. Frozen? Tap for one small step."),
        ]
        return steps.compactMap { step in
            let fire = due.addingTimeInterval(step.offset)
            guard fire > now else { return nil }
            return PlannedReminder(id: "\(itemID.uuidString).\(step.suffix)", itemID: itemID, fireDate: fire, title: title, body: step.body)
        }
    }

    /// Generic money copy for callers that only have the protocol's `EscalationKind` (no service
    /// name split or Apple flag): `title` is used as the service name.
    public static func genericMoneyReminders(itemID: UUID, title: String, amountCents: Int, due: Date, now: Date, calendar: Calendar = .current) -> [PlannedReminder] {
        moneyReminders(
            itemID: itemID, serviceName: title, amountCents: amountCents, currencyCode: "USD",
            chargeDate: due, billedByApple: false, now: now, calendar: calendar
        )
    }
}

/// Debug "time travel": squeezes the wait before each reminder so a day passes in a minute.
public enum TimeTravel {
    public static let defaultsKey = "debug.timeTravel.enabled"
    /// 1 day → 1 minute.
    public static let factor: Double = 24 * 60

    public static var isEnabled: Bool {
        #if DEBUG
        AppGroup.defaults.bool(forKey: defaultsKey)
        #else
        false
        #endif
    }

    /// Seconds from `now` until `fireDate`, compressed. Never less than 1 s (the trigger minimum).
    public static func compressedInterval(until fireDate: Date, now: Date) -> TimeInterval {
        max(1, fireDate.timeIntervalSince(now) / factor)
    }
}
