import Foundation
import SharedKit
import UserNotifications

/// The parts of `UNUserNotificationCenter` the scheduler uses, so tests can swap in a fake.
public protocol NotificationCenterClient: Sendable {
    func requestAuthorization() async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func pending() async -> [PendingNotification]
    func removePending(ids: [String])
    func removeDelivered(ids: [String])
}

public struct PendingNotification: Sendable, Hashable {
    public var id: String
    public var title: String
}

public struct SystemNotificationCenter: NotificationCenterClient {
    public init() {}

    private var center: UNUserNotificationCenter { .current() }

    public func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    public func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
    }

    public func pending() async -> [PendingNotification] {
        await center.pendingNotificationRequests().map {
            PendingNotification(id: $0.identifier, title: $0.content.title)
        }
    }

    public func removePending(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    public func removeDelivered(ids: [String]) {
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
}

/// The real `EscalationScheduling`: reminder notifications (A2) plus the final-day alarm chain (A4).
public actor EscalationScheduler: EscalationScheduling {
    public static let itemIDKey = "itemID"

    private let center: any NotificationCenterClient
    private let alarms: DeadlineAlarms
    private let now: @Sendable () -> Date

    public init(
        center: any NotificationCenterClient = SystemNotificationCenter(),
        alarms: DeadlineAlarms = DeadlineAlarms(),
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.center = center
        self.alarms = alarms
        self.now = now
    }

    // MARK: MoneyKit API (knows the Apple flag and currency)

    /// Replaces this deadline's reminders and (re)arms its final-day alarm. Decided items get neither.
    /// An alarm chain already running for the same plan is left alone, so resyncing mid-chain is safe.
    public func schedule(deadline: MoneyDeadlineSnapshot) async throws {
        guard deadline.isOpen else {
            await resolve(itemID: deadline.id)
            return
        }
        let current = now()
        // A snooze already replaced the ladder with one nudge (and moved the alarm); leave it.
        if let until = deadline.snoozedUntil, until > current {
            return
        }
        await clearReminders(itemID: deadline.id)
        let reminders = ReminderPlanner.moneyReminders(
            itemID: deadline.id,
            serviceName: deadline.serviceName,
            amountCents: deadline.amountCents,
            currencyCode: deadline.currencyCode,
            chargeDate: deadline.dueDate,
            billedByApple: deadline.billedByApple,
            now: current
        )
        try await add(reminders)

        let title = DeadlineAlarmPlanner.moneyTitle(
            serviceName: deadline.serviceName,
            amountCents: deadline.amountCents,
            currencyCode: deadline.currencyCode,
            billedByApple: deadline.billedByApple
        )
        if let planned = DeadlineAlarmPlanner.moneyFireDate(chargeDate: deadline.dueDate, billedByApple: deadline.billedByApple, now: current) {
            try await alarms.arm(itemID: deadline.id, title: title, planned: planned)
        } else if Self.chargeDayIsOver(deadline.dueDate, now: current) {
            alarms.disarm(itemID: deadline.id)
        }
    }

    static func chargeDayIsOver(_ chargeDate: Date, now: Date, calendar: Calendar = .current) -> Bool {
        guard let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: chargeDate)) else { return true }
        return now >= end
    }

    // MARK: EscalationScheduling

    public func schedule(itemID: UUID, title: String, due: Date, kind: EscalationKind) async throws {
        await clearReminders(itemID: itemID)
        let current = now()
        switch kind {
        case .money(let amountCents):
            try await add(ReminderPlanner.genericMoneyReminders(itemID: itemID, title: title, amountCents: amountCents, due: due, now: current))
            if let planned = DeadlineAlarmPlanner.moneyFireDate(chargeDate: due, billedByApple: false, now: current) {
                let alarmTitle = DeadlineAlarmPlanner.moneyTitle(serviceName: title, amountCents: amountCents, currencyCode: "USD", billedByApple: false)
                try await alarms.arm(itemID: itemID, title: alarmTitle, planned: planned)
            }
        case .task:
            try await add(ReminderPlanner.taskReminders(itemID: itemID, title: title, due: due, now: current))
            if due > current {
                try await alarms.arm(itemID: itemID, title: "\(title) is due now", planned: due)
            }
        }
    }

    /// Clears the ladder, sends one gentle nudge at `until`, and moves any alarm there too.
    public func snooze(itemID: UUID, until: Date) async throws {
        let title = await center.pending()
            .first { $0.id.hasPrefix(itemID.uuidString) }?
            .title ?? "Parachute"
        let alarm = alarms.record(for: itemID)
        await resolve(itemID: itemID)
        try await add([PlannedReminder(
            id: "\(itemID.uuidString).snooze",
            itemID: itemID,
            fireDate: until,
            title: title,
            body: "You snoozed this. Ready to decide now?"
        )])
        if let alarm {
            try await alarms.arm(itemID: itemID, title: alarm.title, planned: until)
        }
    }

    /// A decision was recorded: no more reminders, no more alarm.
    public func resolve(itemID: UUID) async {
        await clearReminders(itemID: itemID)
        alarms.disarm(itemID: itemID)
    }

    private func clearReminders(itemID: UUID) async {
        let ids = await center.pending().map(\.id).filter { $0.hasPrefix(itemID.uuidString) }
        center.removePending(ids: ids)
        center.removeDelivered(ids: ids)
    }

    // MARK: Private

    private func add(_ reminders: [PlannedReminder]) async throws {
        guard !reminders.isEmpty else { return }
        _ = try? await center.requestAuthorization()
        let current = now()
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.userInfo = [Self.itemIDKey: reminder.itemID.uuidString]
            try await center.add(UNNotificationRequest(
                identifier: reminder.id,
                content: content,
                trigger: Self.trigger(for: reminder.fireDate, now: current)
            ))
        }
    }

    static func trigger(for fireDate: Date, now: Date) -> UNNotificationTrigger {
        if TimeTravel.isEnabled {
            return UNTimeIntervalNotificationTrigger(timeInterval: TimeTravel.compressedInterval(until: fireDate, now: now), repeats: false)
        }
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
}

/// A Sendable copy of the fields the scheduler needs (SwiftData models can't cross actors).
public struct MoneyDeadlineSnapshot: Sendable, Hashable {
    public var id: UUID
    public var serviceName: String
    public var amountCents: Int
    public var currencyCode: String
    public var dueDate: Date
    public var billedByApple: Bool
    public var isOpen: Bool
    public var snoozedUntil: Date?

    public init(_ deadline: MoneyDeadline) {
        id = deadline.id
        serviceName = deadline.serviceName
        amountCents = deadline.amountCents
        currencyCode = deadline.currencyCode
        dueDate = deadline.dueDate
        billedByApple = deadline.billedByApple
        isOpen = deadline.isOpen
        snoozedUntil = deadline.status == .snoozed ? deadline.snoozedUntil : nil
    }

    public init(id: UUID, serviceName: String, amountCents: Int, currencyCode: String = "USD", dueDate: Date, billedByApple: Bool, isOpen: Bool = true, snoozedUntil: Date? = nil) {
        self.id = id
        self.serviceName = serviceName
        self.amountCents = amountCents
        self.currencyCode = currencyCode
        self.dueDate = dueDate
        self.billedByApple = billedByApple
        self.isOpen = isOpen
        self.snoozedUntil = snoozedUntil
    }
}
