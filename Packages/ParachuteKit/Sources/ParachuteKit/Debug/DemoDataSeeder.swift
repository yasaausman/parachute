#if DEBUG
import Foundation
import SharedKit
import SwiftData

/// P2: realistic data for the demo video ("$214 back · 12 tasks · best run 5 days", docs/demo-script.md).
/// Replaces Parachute's own records and tasks; adds money deadlines only when there are none (they're Dev A's).
/// Only Apple-billed trials go to Apple's page (CLAUDE.md rule 8).
@MainActor
public enum DemoDataSeeder {
    public static func seed(in context: ModelContext, now: Date = .now) {
        try? context.delete(model: CompletionRecord.self)
        try? context.delete(model: MicroStep.self)
        try? context.delete(model: FrozenTask.self)

        let calendar = Calendar.current
        func daysAgo(_ n: Int, hour: Int = 15) -> Date {
            let day = calendar.date(byAdding: .day, value: -n, to: calendar.startOfDay(for: now)) ?? now
            return calendar.date(byAdding: .hour, value: hour, to: day) ?? day
        }

        // Days 1–5 ago are the 5-day best run; the other days are split up by gaps.
        let cancelled: [(String, Int, Int)] = [
            ("Cancelled Adobe Creative Cloud", 5999, 1), ("Cancelled LinkedIn Premium", 3999, 3),
            ("Cancelled Duolingo Max", 2999, 5), ("Cancelled Grammarly", 3000, 9),
            ("Cancelled Hulu", 1799, 12), ("Cancelled Audible", 1495, 2),
            ("Cancelled YouTube Premium", 1399, 16), ("Cancelled Peacock", 799, 20),
        ]
        for (title, cents, day) in cancelled {
            context.insert(CompletionRecord(kind: .moneyCancelled, title: title, amountCents: cents, date: daysAgo(day)))
        }
        context.insert(CompletionRecord(kind: .moneyKept, title: "Kept Spotify", amountCents: 1199, date: daysAgo(7)))

        let tasks: [(String, Int)] = [
            ("Wrote history essay intro", 1), ("Emailed professor about extension", 2), ("Filed FAFSA renewal", 3),
            ("Submitted lab report", 4), ("Updated resume", 4), ("Replied to advisor", 5),
            ("Booked doctor's appointment", 8), ("Made group project slides", 9), ("Renewed driver's license", 12),
            ("Wrote cover letter", 14), ("Sent landlord the heater email", 17), ("Studied for calculus midterm", 21),
        ]
        for (title, day) in tasks {
            context.insert(CompletionRecord(kind: .taskDone, title: title, date: daysAgo(day, hour: 20)))
        }

        let essay = UnfreezePlan(steps: [
            PlanStep(text: "Open a blank doc. Type your name at the top.", seconds: 10),
            PlanStep(text: "Write your thesis in one messy sentence.", seconds: 60),
            PlanStep(text: "List three reasons that support it.", seconds: 90),
            PlanStep(text: "Write the first sentence of paragraph one.", seconds: 60),
            PlanStep(text: "Finish paragraph one. Messy is fine.", seconds: 90),
            PlanStep(text: "Paste one quote you could use.", seconds: 60),
            PlanStep(text: "Read it once out loud and fix one thing.", seconds: 90),
        ], source: .ai, isSuggested: true)
        let task = TaskStore.create(title: "8-page history essay", dueDate: now.addingTimeInterval(6 * 3600), plan: essay, in: context)
        TaskStore.sync(task, steps: essay.steps, nextIndex: 2, in: context)

        if ((try? context.fetchCount(FetchDescriptor<MoneyDeadline>())) ?? 0) == 0 {
            let day: TimeInterval = 86_400
            context.insert(MoneyDeadline(serviceName: "Hulu", amountCents: 1799, dueDate: now.addingTimeInterval(3 * day), billedByApple: false))
            context.insert(MoneyDeadline(serviceName: "Claude Pro", serviceID: "claude", amountCents: 2000, dueDate: now.addingTimeInterval(7 * day), billedByApple: false))
            context.insert(MoneyDeadline(serviceName: "Apple One", serviceID: "apple-one", amountCents: 1995, dueDate: now.addingTimeInterval(2 * day), billedByApple: true))
        }
        try? context.save()
        WidgetRefresh.now()
    }
}
#endif
