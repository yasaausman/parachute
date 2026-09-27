import SharedKit
import SwiftData
import Foundation

public struct DemoDataSeeder {
    /// Only call in DEBUG. Seeds the container with realistic demo data.
    @MainActor
    public static func seed(in context: ModelContext) {
        // Sample CompletionRecords
        let records: [(CompletionKind, String, Int?, Int)] = [
            (.moneyCancelled, "Cancelled Hulu", 1799, -5),    // 5 days ago
            (.moneyCancelled, "Cancelled Adobe CC", 5499, -3), // 3 days ago
            (.taskDone, "Wrote history essay", nil, -4),
            (.taskDone, "Filed FAFSA renewal", nil, -2),
            (.taskDone, "Submitted lab report", nil, -1),
            (.moneyCancelled, "Cancelled YouTube Premium", 1399, -1),
        ]
        for (kind, title, amount, daysAgo) in records {
            let record = CompletionRecord(
                kind: kind,
                title: title,
                amountCents: amount,
                date: Calendar.current.date(byAdding: .day, value: daysAgo, to: .now)!
            )
            context.insert(record)
        }
        
        // Sample frozen tasks
        let activeTask = FrozenTask(
            title: "8-page history essay",
            dueDate: Calendar.current.date(byAdding: .hour, value: 6, to: .now)
        )
        // Add some sample steps
        let steps = [
            MicroStep(order: 0, text: "Open a blank doc. Type your name.", seconds: 10, source: .ai, doneAt: .now),
            MicroStep(order: 1, text: "Write your thesis in one sentence.", seconds: 60, source: .ai, doneAt: .now),
            MicroStep(order: 2, text: "List 3 main arguments.", seconds: 90, source: .ai),
            MicroStep(order: 3, text: "Write the first paragraph.", seconds: 90, source: .ai),
            MicroStep(order: 4, text: "Write the second paragraph.", seconds: 90, source: .ai),
            MicroStep(order: 5, text: "Write the conclusion.", seconds: 90, source: .ai),
            MicroStep(order: 6, text: "Read it once and fix obvious errors.", seconds: 90, source: .ai),
        ]
        activeTask.steps = steps
        context.insert(activeTask)
        
        // Sample money deadlines for widget testing
        // Note: MoneyDeadline is Dev A's model but we need some for demo/widgets
        let deadlines: [(String, Int, Int, Bool)] = [
            // (name, amountCents, daysUntilDue, billedByApple)
            ("Hulu", 1799, 3, false),
            ("Claude Pro", 2000, 7, false),
            ("Apple One", 1695, 1, true),
        ]
        for (name, amount, days, apple) in deadlines {
            let deadline = MoneyDeadline(
                serviceName: name,
                amountCents: amount,
                dueDate: Calendar.current.date(byAdding: .day, value: days, to: .now)!,
                billedByApple: apple
            )
            context.insert(deadline)
        }
        
        try? context.save()
    }
}
