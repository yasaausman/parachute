import SharedKit
import SwiftData

/// B6: the real `CompletionLedger`. Writes `CompletionRecord`s into the shared App Group store,
/// where the scoreboard's `@Query` picks them up. Snoozes are never recorded.
public actor SwiftDataLedger: CompletionLedger {
    private let container: ModelContainer

    public init(modelContainer: ModelContainer) {
        container = modelContainer
    }

    public func record(kind: CompletionKind, title: String, amountCents: Int?) async {
        let context = ModelContext(container)
        context.insert(CompletionRecord(kind: kind, title: title, amountCents: amountCents))
        try? context.save()
    }
}
