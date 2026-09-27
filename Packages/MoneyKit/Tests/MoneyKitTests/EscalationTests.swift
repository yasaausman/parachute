import Foundation
import SharedKit
import Synchronization
import Testing
import UserNotifications
@testable import MoneyKit

@Suite struct ReminderPlannerTests {
    static let calendar = DeadlineMathTests.calendar
    static func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0, _ min: Int = 0) -> Date {
        DeadlineMathTests.date(y, m, d, h, min)
    }

    let id = UUID()
    let now = Self.date(2026, 9, 26, 18, 20)

    @Test func webTrialGetsThreeDayAndOneDayReminders() throws {
        let reminders = ReminderPlanner.moneyReminders(
            itemID: id, serviceName: "Spotify", amountCents: 699, currencyCode: "USD",
            chargeDate: Self.date(2026, 10, 3), billedByApple: false, now: now, calendar: Self.calendar
        )
        #expect(reminders.map(\.fireDate) == [Self.date(2026, 9, 30, 10), Self.date(2026, 10, 2, 10)])
        #expect(reminders.map(\.title) == ["Spotify · $6.99 in 3 days", "Spotify · $6.99 tomorrow"])
        #expect(reminders[1].body.hasPrefix("$6.99 leaves your account tomorrow"))
        #expect(reminders.map(\.id) == ["\(id.uuidString).r3", "\(id.uuidString).r1"])
    }

    @Test func appleTrialRemindersComeADayEarlier() {
        let reminders = ReminderPlanner.moneyReminders(
            itemID: id, serviceName: "Apple One", amountCents: 2195, currencyCode: "USD",
            chargeDate: Self.date(2026, 10, 3), billedByApple: true, now: now, calendar: Self.calendar
        )
        #expect(reminders.map(\.fireDate) == [Self.date(2026, 9, 29, 10), Self.date(2026, 10, 1, 10)])
        #expect(reminders.map(\.title) == ["Apple One · $21.95 in 4 days", "Apple One · $21.95 in 2 days"])
        #expect(reminders[1].body.contains("cancel by tomorrow"))
    }

    @Test func pastRemindersAreSkipped() {
        let reminders = ReminderPlanner.moneyReminders(
            itemID: id, serviceName: "Hulu", amountCents: 1799, currencyCode: "USD",
            chargeDate: Self.date(2026, 9, 28), billedByApple: false, now: now, calendar: Self.calendar
        )
        // -3d (Sep 25) is gone; -1d (Sep 27 10:00) is still ahead.
        #expect(reminders.map(\.fireDate) == [Self.date(2026, 9, 27, 10)])
    }

    @Test func taskDueInFiveMinutesStillGetsTheDueReminder() {
        let due = now.addingTimeInterval(5 * 60)
        let reminders = ReminderPlanner.taskReminders(itemID: id, title: "History essay", due: due, now: now)
        #expect(reminders.map(\.fireDate) == [due])
        #expect(reminders.first?.id == "\(id.uuidString).t0")
    }

    @Test func taskDueInTwoDaysGetsTheWholeLadder() {
        let due = now.addingTimeInterval(2 * 24 * 60 * 60)
        #expect(ReminderPlanner.taskReminders(itemID: id, title: "Essay", due: due, now: now).count == 3)
    }

    @Test func timeTravelTurnsADayIntoAMinute() {
        #expect(TimeTravel.compressedInterval(until: now.addingTimeInterval(86_400), now: now) == 60)
        #expect(TimeTravel.compressedInterval(until: now.addingTimeInterval(10), now: now) == 1)
    }
}

/// Records what the scheduler asks the notification center to do.
final class FakeNotificationCenter: NotificationCenterClient {
    let requests = Mutex<[PendingNotification]>([])

    var ids: [String] { requests.withLock { $0.map(\.id) } }

    func requestAuthorization() async throws -> Bool { true }

    func add(_ request: UNNotificationRequest) async throws {
        let entry = PendingNotification(id: request.identifier, title: request.content.title)
        requests.withLock { list in
            list.removeAll { $0.id == entry.id }
            list.append(entry)
        }
    }

    func pending() async -> [PendingNotification] { requests.withLock { $0 } }

    func removePending(ids: [String]) {
        requests.withLock { list in list.removeAll { ids.contains($0.id) } }
    }

    func removeDelivered(ids: [String]) {}
}

@Suite struct EscalationSchedulerTests {
    let center = FakeNotificationCenter()
    let now = ReminderPlannerTests.date(2026, 9, 26, 18, 20)
    let suite = "test.alarms.\(UUID().uuidString)"
    var scheduler: EscalationScheduler {
        let now = self.now
        let alarms = DeadlineAlarms(suiteName: suite, client: FakeAlarmClient(), now: { now }, timeTravel: { false })
        return EscalationScheduler(center: center, alarms: alarms, now: { now })
    }

    func snapshot(id: UUID, isOpen: Bool = true) -> MoneyDeadlineSnapshot {
        MoneyDeadlineSnapshot(id: id, serviceName: "Spotify", amountCents: 699, dueDate: now.addingTimeInterval(7 * 86_400), billedByApple: false, isOpen: isOpen)
    }

    @Test func schedulingTwiceReplacesInsteadOfDuplicating() async throws {
        let id = UUID()
        try await scheduler.schedule(deadline: snapshot(id: id))
        try await scheduler.schedule(deadline: snapshot(id: id))
        #expect(center.ids.sorted() == ["\(id.uuidString).r1", "\(id.uuidString).r3"])
    }

    @Test func resolveRemovesOnlyThatItem() async throws {
        let a = UUID(), b = UUID()
        try await scheduler.schedule(deadline: snapshot(id: a))
        try await scheduler.schedule(deadline: snapshot(id: b))
        await scheduler.resolve(itemID: a)
        #expect(center.ids.allSatisfy { $0.hasPrefix(b.uuidString) })
        #expect(center.ids.count == 2)
    }

    @Test func decidedItemsGetNoReminders() async throws {
        try await scheduler.schedule(deadline: snapshot(id: UUID(), isOpen: false))
        #expect(center.ids.isEmpty)
    }

    @Test func snoozeReplacesTheLadderWithOneNudge() async throws {
        let id = UUID()
        try await scheduler.schedule(deadline: snapshot(id: id))
        try await scheduler.snooze(itemID: id, until: now.addingTimeInterval(3600))
        let requests = await center.pending()
        #expect(requests.map(\.id) == ["\(id.uuidString).snooze"])
        #expect(requests.first?.title.hasPrefix("Spotify") == true)
    }

    @Test func protocolTaskPathSchedulesTaskLadder() async throws {
        let id = UUID()
        try await scheduler.schedule(itemID: id, title: "Essay", due: now.addingTimeInterval(300), kind: .task)
        #expect(center.ids == ["\(id.uuidString).t0"])
    }
}
