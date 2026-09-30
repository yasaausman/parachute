import Foundation
import SharedKit
import Synchronization
import Testing
@testable import MoneyKit

/// Records what the chain asks AlarmKit to do.
final class FakeAlarmClient: AlarmClient {
    struct Scheduled: Sendable, Hashable {
        var alarmID: UUID
        var itemID: UUID
        var title: String
        var date: Date
    }

    let scheduled = Mutex<[Scheduled]>([])
    let cancelled = Mutex<[UUID]>([])

    var live: [Scheduled] {
        let gone = cancelled.withLock { $0 }
        return scheduled.withLock { $0 }.filter { !gone.contains($0.alarmID) }
    }

    func requestAuthorizationIfNeeded() async -> Bool { true }

    func schedule(alarmID: UUID, itemID: UUID, title: String, at date: Date) async throws {
        scheduled.withLock { $0.append(Scheduled(alarmID: alarmID, itemID: itemID, title: title, date: date)) }
    }

    func cancel(alarmID: UUID) {
        cancelled.withLock { $0.append(alarmID) }
    }
}

@Suite struct DeadlineAlarmPlannerTests {
    static let calendar = DeadlineMathTests.calendar
    static func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0, _ min: Int = 0) -> Date {
        DeadlineMathTests.date(y, m, d, h, min)
    }

    let now = Self.date(2026, 9, 26, 18, 20)
    let charge = Self.date(2026, 10, 3)

    @Test func webTrialRingsAtNineOnChargeDay() {
        #expect(DeadlineAlarmPlanner.moneyFireDate(chargeDate: charge, billedByApple: false, now: now, calendar: Self.calendar) == Self.date(2026, 10, 3, 9))
    }

    @Test func appleTrialRingsTheDayBefore() {
        #expect(DeadlineAlarmPlanner.moneyFireDate(chargeDate: charge, billedByApple: true, now: now, calendar: Self.calendar) == Self.date(2026, 10, 2, 9))
    }

    @Test func addedLateOnTheLastDayRingsInAMinute() {
        let late = Self.date(2026, 10, 3, 13, 0)
        #expect(DeadlineAlarmPlanner.moneyFireDate(chargeDate: charge, billedByApple: false, now: late, calendar: Self.calendar) == late.addingTimeInterval(60))
    }

    @Test func noAlarmOnceTheLastDayIsOver() {
        #expect(DeadlineAlarmPlanner.moneyFireDate(chargeDate: charge, billedByApple: false, now: Self.date(2026, 10, 4, 8), calendar: Self.calendar) == nil)
    }

    @Test func titlesLeadWithTheMoney() {
        #expect(DeadlineAlarmPlanner.moneyTitle(serviceName: "Spotify", amountCents: 699, currencyCode: "USD", billedByApple: false) == "Spotify charges $6.99 today")
        #expect(DeadlineAlarmPlanner.moneyTitle(serviceName: "Apple One", amountCents: 2195, currencyCode: "USD", billedByApple: true) == "Cancel Apple One today · $21.95 tomorrow")
    }

    @Test func timeTravelSqueezesButNotBelowTenSeconds() {
        #expect(DeadlineAlarmPlanner.rearmDelay(timeTravel: false) == 1800)
        #expect(DeadlineAlarmPlanner.rearmDelay(timeTravel: true) == 60)
        let inADay = now.addingTimeInterval(86_400)
        #expect(DeadlineAlarmPlanner.effectiveFireDate(inADay, now: now, timeTravel: true) == now.addingTimeInterval(60))
        #expect(DeadlineAlarmPlanner.effectiveFireDate(now.addingTimeInterval(5), now: now, timeTravel: true) == now.addingTimeInterval(10))
        #expect(DeadlineAlarmPlanner.effectiveFireDate(inADay, now: now, timeTravel: false) == inADay)
    }
}

@Suite struct DeadlineAlarmChainTests {
    let client = FakeAlarmClient()
    let suite = "test.alarms.\(UUID().uuidString)"
    let now = DeadlineAlarmPlannerTests.date(2026, 10, 3, 9, 0)
    let item = UUID()

    var alarms: DeadlineAlarms {
        let now = self.now
        return DeadlineAlarms(suiteName: suite, client: client, now: { now }, timeTravel: { false })
    }

    @Test func armSchedulesOneAlarmAndRemembersIt() async throws {
        try await alarms.arm(itemID: item, title: "Spotify charges $6.99 today", planned: now)
        #expect(client.live.count == 1)
        #expect(alarms.record(for: item)?.rings == 0)
    }

    @Test func rearmingTheSamePlanKeepsTheRunningChain() async throws {
        try await alarms.arm(itemID: item, title: "T", planned: now)
        try await alarms.stopTapped(itemID: item)
        try await alarms.arm(itemID: item, title: "T", planned: now)
        #expect(client.scheduled.withLock { $0.count } == 2, "resync mid-chain must not reset it")
        #expect(alarms.record(for: item)?.rings == 1)
    }

    @Test func aNewPlanReplacesTheOldAlarm() async throws {
        try await alarms.arm(itemID: item, title: "T", planned: now)
        try await alarms.arm(itemID: item, title: "T", planned: now.addingTimeInterval(86_400))
        #expect(client.live.count == 1)
        #expect(client.live.first?.date == now.addingTimeInterval(86_400))
    }

    @Test func stopBringsItBackInThirtyMinutes() async throws {
        try await alarms.arm(itemID: item, title: "T", planned: now)
        try await alarms.stopTapped(itemID: item)
        try await alarms.stopTapped(itemID: item)
        #expect(client.live.count == 1)
        #expect(client.live.first?.date == now.addingTimeInterval(1800))
        #expect(alarms.record(for: item)?.rings == 2)
    }

    @Test @MainActor func decideOpensTheAppAndKeepsASafetyRing() async throws {
        try await alarms.arm(itemID: item, title: "T", planned: now)
        try await alarms.decideTapped(itemID: item)
        #expect(DecideRouter.shared.pending?.itemID == item)
        #expect(client.live.count == 1, "still re-rings if the app is closed without deciding")
    }

    /// Dev A's iPhone, 2026-09-28: a Debug "ring in 1 minute" alarm was replaced by the next
    /// resync (foreground / Pro change) and never rang.
    @Test func aResyncDoesNotReplaceAPendingTestRing() async throws {
        try await alarms.ringForTest(itemID: item, title: "T", at: now.addingTimeInterval(60))
        try await alarms.arm(itemID: item, title: "T", planned: now.addingTimeInterval(86_400))
        #expect(client.live.count == 1)
        #expect(client.live.first?.date == now.addingTimeInterval(60))
    }

    /// Dev A's iPhone, 2026-09-28: armed under time travel (Dec 7 squeezed to ~71 minutes),
    /// then time travel off → the resync kept the squeezed time, so it would ring at midnight.
    @Test func turningTimeTravelOffMovesTheAlarmBackToTheRealDate() async throws {
        let travel = TimeTravelSwitch(on: true)
        let now = self.now
        let chain = DeadlineAlarms(suiteName: suite, client: client, now: { now }, timeTravel: { travel.on })
        let planned = now.addingTimeInterval(70 * 86_400)
        try await chain.arm(itemID: item, title: "T", planned: planned)
        #expect(client.live.first?.date == now.addingTimeInterval(70 * 60))
        travel.on = false
        try await chain.arm(itemID: item, title: "T", planned: planned)
        #expect(client.live.count == 1)
        #expect(client.live.first?.date == planned)
    }

    @Test func aDecisionEndsTheChainForGood() async throws {
        try await alarms.arm(itemID: item, title: "T", planned: now)
        try await alarms.stopTapped(itemID: item)
        alarms.disarm(itemID: item)
        #expect(client.live.isEmpty)
        try await alarms.stopTapped(itemID: item)
        #expect(client.live.isEmpty, "a late Stop after deciding must not re-arm")
        #expect(alarms.record(for: item) == nil)
    }
}

@Suite struct SchedulerAlarmTests {
    let center = FakeNotificationCenter()
    let client = FakeAlarmClient()
    let suite = "test.alarms.\(UUID().uuidString)"
    let now = DeadlineAlarmPlannerTests.date(2026, 9, 26, 18, 20)

    var scheduler: EscalationScheduler {
        let now = self.now
        let alarms = DeadlineAlarms(suiteName: suite, client: client, now: { now }, timeTravel: { false })
        return EscalationScheduler(center: center, alarms: alarms, now: { now })
    }

    @Test func savingATrialArmsTheFinalDayAlarmAndDecidingDisarmsIt() async throws {
        // The scheduler uses the device calendar, so build the dates with it too.
        let local = Calendar.current
        let id = UUID()
        let due = local.date(from: DateComponents(year: 2026, month: 10, day: 3))!
        let snapshot = MoneyDeadlineSnapshot(id: id, serviceName: "Spotify", amountCents: 699, dueDate: due, billedByApple: false)
        try await scheduler.schedule(deadline: snapshot)
        #expect(client.live.map(\.title) == ["Spotify charges $6.99 today"])
        #expect(client.live.first?.date == local.date(from: DateComponents(year: 2026, month: 10, day: 3, hour: 9)))

        await scheduler.resolve(itemID: id)
        #expect(client.live.isEmpty)
        #expect(center.ids.isEmpty)
    }
}

@Suite struct ProAlarmGateTests {
    let center = FakeNotificationCenter()
    let client = FakeAlarmClient()
    let suite = "test.alarms.\(UUID().uuidString)"
    let now = DeadlineAlarmPlannerTests.date(2026, 9, 26, 18, 20)

    func scheduler(pro: Bool) -> EscalationScheduler {
        let now = self.now
        let alarms = DeadlineAlarms(suiteName: suite, client: client, now: { now }, timeTravel: { false })
        return EscalationScheduler(center: center, alarms: alarms, alarmsAllowed: { pro }, now: { now })
    }

    func snapshot(_ id: UUID) -> MoneyDeadlineSnapshot {
        MoneyDeadlineSnapshot(id: id, serviceName: "Spotify", amountCents: 699, dueDate: now.addingTimeInterval(7 * 86_400), billedByApple: false)
    }

    @Test func freeUsersGetRemindersButNoAlarm() async throws {
        let id = UUID()
        try await scheduler(pro: false).schedule(deadline: snapshot(id))
        #expect(center.ids.count == 2)
        #expect(client.live.isEmpty)
    }

    @Test func losingProDisarmsTheChain() async throws {
        let id = UUID()
        try await scheduler(pro: true).schedule(deadline: snapshot(id))
        #expect(client.live.count == 1)
        try await scheduler(pro: false).schedule(deadline: snapshot(id))
        #expect(client.live.isEmpty)
        #expect(center.ids.count == 2, "reminders stay free")
    }
}

final class TimeTravelSwitch: @unchecked Sendable {
    var on: Bool
    init(on: Bool) { self.on = on }
}

@Suite struct ProOverrideTests {
    @Test(arguments: [
        (true, ProEntitlements.DebugOverride.real, true),
        (false, .real, false),
        (false, .pro, true),
        (true, .free, false),
        (false, .free, false),
    ])
    func resolve(real: Bool, override: ProEntitlements.DebugOverride, expected: Bool) {
        #expect(ProEntitlements.resolve(real: real, override: override) == expected)
    }
}
