import Foundation
import SwiftData

/// One tiny step of a `FrozenTask`.
@Model
public final class MicroStep {
    public var order: Int
    /// "Open a blank doc. Type your name."
    public var text: String
    /// ≤ 90.
    public var seconds: Int
    public var sourceRaw: String
    public var doneAt: Date?

    public var source: StepSource {
        get { StepSource(rawValue: sourceRaw) ?? .ai }
        set { sourceRaw = newValue.rawValue }
    }

    public init(order: Int, text: String, seconds: Int, source: StepSource, doneAt: Date? = nil) {
        self.order = order
        self.text = text
        self.seconds = seconds
        self.sourceRaw = source.rawValue
        self.doneAt = doneAt
    }
}

public enum StepSource: String, Codable, Sendable, CaseIterable {
    case curated, appleSubscriptions, ai
}
