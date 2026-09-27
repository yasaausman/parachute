import SwiftData
import SharedKit

@ModelActor
public actor SwiftDataLedger: CompletionLedger {
    public func record(kind: CompletionKind, title: String, amountCents: Int?) async {
        let record = CompletionRecord(kind: kind, title: title, amountCents: amountCents)
        modelContext.insert(record)
        try? modelContext.save()
    }
}
