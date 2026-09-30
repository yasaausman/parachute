import Foundation
import SharedKit
import SwiftData

/// A5: what each Decide choice does to the deadline, the escalation chain, and the scoreboard.
/// Shared by the Decide screen and the app's Unfreeze hand-off so the rules live in one place.
public enum DeadlineDecision: Sendable, Hashable {
    case cancelled
    case kept
    case snoozed(until: Date)

    @MainActor
    public func apply(
        to deadline: MoneyDeadline,
        context: ModelContext,
        escalation: (any EscalationScheduling)?,
        ledger: (any CompletionLedger)?,
        now: Date = .now
    ) async {
        let id = deadline.id
        let name = deadline.serviceName
        switch self {
        case .cancelled:
            deadline.status = .cancelled
            deadline.snoozedUntil = nil
            // Only real dollars count: the charge hasn't gone through yet (PLAN §4).
            let saved = Self.beforeCharge(deadline.dueDate, now: now) ? deadline.amountCents : nil
            guard Self.commit(context) else { return }
            await escalation?.resolve(itemID: id)
            await ledger?.record(kind: .moneyCancelled, title: "Cancelled \(name)", amountCents: saved)
        case .kept:
            deadline.status = .kept
            deadline.snoozedUntil = nil
            guard Self.commit(context) else { return }
            await escalation?.resolve(itemID: id)
            await ledger?.record(kind: .moneyKept, title: "Kept \(name)", amountCents: nil)
        case .snoozed(let until):
            deadline.status = .snoozed
            deadline.snoozedUntil = until
            guard Self.commit(context) else { return }
            try? await escalation?.snooze(itemID: id, until: until)
        }
    }

    /// Saves, or rolls the change back so the alarm chain and ledger never get ahead of what's on disk.
    @MainActor
    private static func commit(_ context: ModelContext) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }

    static func beforeCharge(_ chargeDate: Date, now: Date, calendar: Calendar = .current) -> Bool {
        guard let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: chargeDate)) else { return false }
        return now < end
    }
}

public extension MoneyDeadline {
    /// What "Get unstuck" hands to Dev B's Unfreeze engine.
    var unfreezeRequest: UnfreezeRequest {
        .cancel(serviceID: serviceID, serviceName: serviceName, billedByApple: billedByApple)
    }

    /// The last moment cancelling still avoids the charge: end of the last day to act.
    var lastMomentToAct: Date {
        let calendar = Calendar.current
        let actDay = calendar.startOfDay(for: cancelBy)
        return calendar.date(byAdding: .day, value: 1, to: actDay)?.addingTimeInterval(-60) ?? cancelBy
    }
}
