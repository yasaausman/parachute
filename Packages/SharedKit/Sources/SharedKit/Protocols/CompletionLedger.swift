import Foundation

/// Implemented by Dev B (ParachuteKit). Written to by A and B.
public protocol CompletionLedger: Sendable {
    func record(kind: CompletionKind, title: String, amountCents: Int?) async
}
