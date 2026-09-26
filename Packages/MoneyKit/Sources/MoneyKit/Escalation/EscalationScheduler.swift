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

/// A2: the real `EscalationScheduling`. Local notifications only for now; A4 adds the final-day alarm.
public actor EscalationScheduler: EscalationScheduling {
    public static let itemIDKey = "itemID"

    private let center: any NotificationCenterClient
    private let now: @Sendable () -> Date

    public init(center: any NotificationCenterClient = SystemNotificationCenter(), now: @escaping @Sendable () -> Date = { .now }) {
        self.center = center
        self.now = now
    }

    // MARK: MoneyKit API (knows the Apple flag and currency)

    /// Replaces any reminders for this deadline. Decided items get none.
    public func schedule(deadline: MoneyDeadlineSnapshot) async throws {
        await resolve(itemID: deadline.id)
        guard deadline.isOpen else { return }
        let reminders = ReminderPlanner.moneyReminders(
            itemID: deadline.id,
            serviceName: deadline.serviceName,
            amountCents: deadline.amountCents,
            currencyCode: deadline.currencyCode,
            chargeDate: deadline.dueDate,
            billedByApple: deadline.billedByApple,
            now: now()
        )
        try await add(reminders)
    }

    // MARK: EscalationScheduling

    public func schedule(itemID: UUID, title: String, due: Date, kind: EscalationKind) async throws {
        await resolve(itemID: itemID)
        let reminders: [PlannedReminder]
        switch kind {
        case .money(let amountCents):
            reminders = ReminderPlanner.genericMoneyReminders(itemID: itemID, title: title, amountCents: amountCents, due: due, now: now())
        case .task:
            reminders = ReminderPlanner.taskReminders(itemID: itemID, title: title, due: due, now: now())
        }
        try await add(reminders)
    }

    /// Clears the ladder and sends one gentle nudge at `until`, reusing the item's last title.
    public func snooze(itemID: UUID, until: Date) async throws {
        let title = await center.pending()
            .first { $0.id.hasPrefix(itemID.uuidString) }?
            .title ?? "Parachute"
        await resolve(itemID: itemID)
        try await add([PlannedReminder(
            id: "\(itemID.uuidString).snooze",
            itemID: itemID,
            fireDate: until,
            title: title,
            body: "You snoozed this. Ready to decide now?"
        )])
    }

    public func resolve(itemID: UUID) async {
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

    public init(_ deadline: MoneyDeadline) {
        id = deadline.id
        serviceName = deadline.serviceName
        amountCents = deadline.amountCents
        currencyCode = deadline.currencyCode
        dueDate = deadline.dueDate
        billedByApple = deadline.billedByApple
        isOpen = deadline.isOpen
    }

    public init(id: UUID, serviceName: String, amountCents: Int, currencyCode: String = "USD", dueDate: Date, billedByApple: Bool, isOpen: Bool = true) {
        self.id = id
        self.serviceName = serviceName
        self.amountCents = amountCents
        self.currencyCode = currencyCode
        self.dueDate = dueDate
        self.billedByApple = billedByApple
        self.isOpen = isOpen
    }
}
