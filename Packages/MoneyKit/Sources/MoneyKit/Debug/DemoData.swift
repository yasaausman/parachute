#if DEBUG
import Foundation
import SharedKit
import SwiftData

/// P2: realistic trials for rehearsing and recording the demo. Only Apple-billed trials use the
/// Apple subscriptions path (CLAUDE.md rule 8); the web ones have hand-checked steps.
enum DemoData {
    struct Trial {
        var name: String
        var serviceID: String?
        var cents: Int
        var daysAway: Int
        var billedByApple: Bool
        var status: DeadlineStatus = .tracking
    }

    static let trials: [Trial] = [
        Trial(name: "Spotify", serviceID: "spotify", cents: 1199, daysAway: 3, billedByApple: false),
        Trial(name: "Duolingo", serviceID: nil, cents: 1299, daysAway: 1, billedByApple: true),
        Trial(name: "Claude", serviceID: "claude", cents: 2000, daysAway: 12, billedByApple: false),
        Trial(name: "Google AI Pro", serviceID: "google-one", cents: 1999, daysAway: 20, billedByApple: false),
        Trial(name: "Apple One", serviceID: "apple-one", cents: 2195, daysAway: 9, billedByApple: true, status: .cancelled),
    ]

    /// Replaces every trial with the demo set (so repeated taps can't pile up duplicates).
    @MainActor
    @discardableResult
    static func load(into context: ModelContext, escalation: EscalationScheduler?) async -> Int {
        await clear(context, escalation: escalation)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var added: [MoneyDeadline] = []
        for trial in trials {
            let due = calendar.date(byAdding: .day, value: trial.daysAway, to: today) ?? today
            let deadline = MoneyDeadline(serviceName: trial.name, serviceID: trial.serviceID, amountCents: trial.cents, dueDate: due, billedByApple: trial.billedByApple, status: trial.status)
            context.insert(deadline)
            added.append(deadline)
        }
        try? context.save()
        await escalation?.resync(added)
        return added.count
    }

    @MainActor
    @discardableResult
    static func clear(_ context: ModelContext, escalation: EscalationScheduler?) async -> Int {
        let all = (try? context.fetch(FetchDescriptor<MoneyDeadline>())) ?? []
        for deadline in all {
            let id = deadline.id
            context.delete(deadline)
            await escalation?.resolve(itemID: id)
        }
        try? context.save()
        return all.count
    }
}
#endif
