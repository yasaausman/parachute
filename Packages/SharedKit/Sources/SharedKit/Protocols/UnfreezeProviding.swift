import Foundation

/// Implemented by Dev B (ParachuteKit). Used by the App when Decide → "Get unstuck".
public protocol UnfreezeProviding: Sendable {
    func plan(for request: UnfreezeRequest) async throws -> UnfreezePlan
}

public enum UnfreezeRequest: Sendable, Hashable {
    case cancel(serviceID: String?, serviceName: String, billedByApple: Bool)
    case task(title: String, dueDate: Date?)
}

public struct UnfreezePlan: Sendable, Hashable {
    public var steps: [PlanStep]
    /// curated / appleSubscriptions / ai
    public var source: StepSource
    /// True for AI → the UI shows "Suggested steps".
    public var isSuggested: Bool

    public init(steps: [PlanStep], source: StepSource, isSuggested: Bool) {
        self.steps = steps
        self.source = source
        self.isSuggested = isSuggested
    }
}

public struct PlanStep: Sendable, Hashable, Codable {
    public var text: String
    /// ≤ 90.
    public var seconds: Int
    /// Curated only; AI must never produce URLs.
    public var url: URL?

    public init(text: String, seconds: Int, url: URL? = nil) {
        self.text = text
        self.seconds = seconds
        self.url = url
    }
}

public enum UnfreezeOutcome: Sendable, Hashable {
    case completed
    case gaveUp
    case snoozed(until: Date)
}
