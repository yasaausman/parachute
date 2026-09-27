import Foundation
import SharedKit
import SwiftData
import Testing
@testable import MoneyKit

@MainActor
@Suite struct DeadlineDecisionTests {
    let container = try! SharedStore.makeContainer(inMemory: true)
    let escalation = FakeEscalationScheduler()
    let ledger = InMemoryLedger()
    let now = Date(timeIntervalSince1970: 1_790_000_000)

    func insert(dueIn days: Double, billedByApple: Bool = false) -> MoneyDeadline {
        let deadline = MoneyDeadline(serviceName: "Spotify", serviceID: "spotify", amountCents: 699, dueDate: now.addingTimeInterval(days * 86_400), billedByApple: billedByApple)
        container.mainContext.insert(deadline)
        return deadline
    }

    @Test func cancelBeforeTheChargeCountsTheMoney() async {
        let deadline = insert(dueIn: 3)
        await DeadlineDecision.cancelled.apply(to: deadline, context: container.mainContext, escalation: escalation, ledger: ledger, now: now)
        #expect(deadline.status == .cancelled)
        #expect(await escalation.calls == [.resolve(itemID: deadline.id)])
        let entry = await ledger.entries.first
        #expect(entry?.kind == .moneyCancelled)
        #expect(entry?.title == "Cancelled Spotify")
        #expect(entry?.amountCents == 699)
    }

    @Test func cancelAfterTheChargeDayCountsNoMoney() async {
        let deadline = insert(dueIn: -2)
        await DeadlineDecision.cancelled.apply(to: deadline, context: container.mainContext, escalation: escalation, ledger: ledger, now: now)
        #expect(await ledger.entries.first?.amountCents == nil)
    }

    @Test func keepStopsAllNaggingAndCountsNoMoney() async {
        let deadline = insert(dueIn: 3)
        await DeadlineDecision.kept.apply(to: deadline, context: container.mainContext, escalation: escalation, ledger: ledger, now: now)
        #expect(deadline.status == .kept)
        #expect(!deadline.isOpen)
        #expect(await escalation.calls == [.resolve(itemID: deadline.id)])
        let entry = await ledger.entries.first
        #expect(entry?.kind == .moneyKept)
        #expect(entry?.amountCents == nil)
    }

    @Test func snoozeMovesTheChainAndStaysOpen() async {
        let deadline = insert(dueIn: 3)
        let until = now.addingTimeInterval(3600)
        await DeadlineDecision.snoozed(until: until).apply(to: deadline, context: container.mainContext, escalation: escalation, ledger: ledger, now: now)
        #expect(deadline.status == .snoozed)
        #expect(deadline.snoozedUntil == until)
        #expect(deadline.isOpen)
        #expect(await escalation.calls == [.snooze(itemID: deadline.id, until: until)])
        #expect(await ledger.entries.isEmpty, "snoozing isn't a win or a loss")
    }

    @Test func frozenHandsTheServiceToUnfreeze() {
        let deadline = insert(dueIn: 3, billedByApple: true)
        #expect(deadline.unfreezeRequest == .cancel(serviceID: "spotify", serviceName: "Spotify", billedByApple: true))
    }
}

@Suite struct SnoozeOptionsTests {
    static let calendar = DeadlineMathTests.calendar
    static func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0, _ min: Int = 0) -> Date {
        DeadlineMathTests.date(y, m, d, h, min)
    }

    @Test func afternoonGetsAllThree() {
        let options = SnoozeOptions.options(now: Self.date(2026, 9, 26, 14), lastMoment: Self.date(2026, 10, 2, 23, 59), calendar: Self.calendar)
        #expect(options.map(\.label) == ["In 1 hour", "Tonight at 8", "Tomorrow at 9"])
        #expect(options[1].date == Self.date(2026, 9, 26, 20))
    }

    @Test func lateEveningSkipsTonight() {
        let options = SnoozeOptions.options(now: Self.date(2026, 9, 26, 19, 30), lastMoment: Self.date(2026, 10, 2, 23, 59), calendar: Self.calendar)
        #expect(options.map(\.label) == ["In 1 hour", "Tomorrow at 9"])
    }

    @Test func neverPastTheLastMomentToAct() {
        let options = SnoozeOptions.options(now: Self.date(2026, 10, 2, 14), lastMoment: Self.date(2026, 10, 2, 23, 59), calendar: Self.calendar)
        #expect(options.map(\.label) == ["In 1 hour", "Tonight at 8"])
    }
}

@Suite struct SnoozeRespectingSchedulerTests {
    let center = FakeNotificationCenter()
    let client = FakeAlarmClient()
    let suite = "test.alarms.\(UUID().uuidString)"
    let now = Date(timeIntervalSince1970: 1_790_000_000)

    @Test func resyncDoesNotUndoAnActiveSnooze() async throws {
        let now = self.now
        let alarms = DeadlineAlarms(suiteName: suite, client: client, now: { now }, timeTravel: { false })
        let scheduler = EscalationScheduler(center: center, alarms: alarms, now: { now })
        let id = UUID()
        let snoozed = MoneyDeadlineSnapshot(id: id, serviceName: "Spotify", amountCents: 699, dueDate: now.addingTimeInterval(3 * 86_400), billedByApple: false, snoozedUntil: now.addingTimeInterval(3600))
        try await scheduler.snooze(itemID: id, until: now.addingTimeInterval(3600))
        let before = center.ids
        try await scheduler.schedule(deadline: snoozed)
        #expect(center.ids == before)
        #expect(center.ids == ["\(id.uuidString).snooze"])
    }
}
