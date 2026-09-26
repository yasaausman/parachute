import Foundation

/// Keeps records in memory. Swap for ParachuteKit's SwiftData ledger once B6 lands.
public actor InMemoryLedger: CompletionLedger {
    public struct Entry: Sendable, Hashable {
        public var kind: CompletionKind
        public var title: String
        public var amountCents: Int?
        public var date: Date
    }

    public private(set) var entries: [Entry] = []

    public init() {}

    public func record(kind: CompletionKind, title: String, amountCents: Int?) async {
        print("[InMemoryLedger] \(kind.rawValue): \(title) \(amountCents.map(String.init) ?? "-")")
        entries.append(Entry(kind: kind, title: title, amountCents: amountCents, date: .now))
    }
}
