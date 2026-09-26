import Foundation

/// Returns a fixed 5-step plan. Swap for ParachuteKit's UnfreezeEngine once B3 lands.
public struct FakeUnfreezeProvider: UnfreezeProviding {
    public init() {}

    public func plan(for request: UnfreezeRequest) async throws -> UnfreezePlan {
        let name: String
        switch request {
        case .cancel(_, let serviceName, _): name = serviceName
        case .task(let title, _): name = title
        }
        return UnfreezePlan(
            steps: [
                PlanStep(text: "Put your phone on the table in front of you.", seconds: 10),
                PlanStep(text: "Open \(name). That's it.", seconds: 20),
                PlanStep(text: "Find the Account or Settings page.", seconds: 45),
                PlanStep(text: "Tap the button that looks like the next step.", seconds: 45),
                PlanStep(text: "Take a screenshot of what you see.", seconds: 15),
            ],
            source: .ai,
            isSuggested: true
        )
    }
}
