import Foundation
import SwiftData

/// A win for the "ADHD Tax Refunded" scoreboard. Written by A (money) and B (tasks), read by B.
@Model
public final class CompletionRecord {
    public var id: UUID
    public var kindRaw: String
    /// "Cancelled Hulu" / "Wrote history essay"
    public var title: String
    /// Only for `.moneyCancelled`: real dollars only.
    public var amountCents: Int?
    public var date: Date

    public var kind: CompletionKind {
        get { CompletionKind(rawValue: kindRaw) ?? .taskDone }
        set { kindRaw = newValue.rawValue }
    }

    public init(id: UUID = UUID(), kind: CompletionKind, title: String, amountCents: Int? = nil, date: Date = .now) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.title = title
        self.amountCents = amountCents
        self.date = date
    }
}

public enum CompletionKind: String, Codable, Sendable, CaseIterable {
    case moneyCancelled, moneyKept, taskDone
}
