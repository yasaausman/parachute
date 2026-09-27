import Foundation
import SharedKit

public actor UnfreezeEngine: UnfreezeProviding {
    private let loader = CancelStepsLoader()
    private let atomizer = AIAtomizer()

    public init() {}

    public func plan(for request: UnfreezeRequest) async throws -> UnfreezePlan {
        switch request {
        case .cancel(let serviceID, let serviceName, let billedByApple):
            // 1. If serviceID matches -> curated
            if let id = serviceID, let plan = try? await loader.plan(forServiceID: id) {
                return plan
            }
            // 2. If serviceName fuzzy-matches -> curated
            if let plan = try? await loader.plan(forServiceName: serviceName) {
                return plan
            }
            // 3. If billedByApple -> Apple subscriptions path
            if billedByApple {
                let steps = [
                    PlanStep(text: "Open Settings. Tap your name at the top.", seconds: 20),
                    PlanStep(text: "Tap 'Subscriptions'.", seconds: 10),
                    PlanStep(text: "Find '\(serviceName)' and tap it.", seconds: 15),
                    PlanStep(text: "Tap 'Cancel Subscription'.", seconds: 10),
                    PlanStep(text: "Confirm the cancellation. Screenshot the confirmation.", seconds: 15)
                ]
                return UnfreezePlan(steps: steps, source: .appleSubscriptions, isSuggested: false)
            }
            // 4. Else -> AI fallback
            let aiSteps = try await atomizer.atomizeCancel(serviceName: serviceName)
            return UnfreezePlan(steps: aiSteps, source: .ai, isSuggested: true)

        case .task(let title, let dueDate):
            let aiSteps = try await atomizer.atomize(taskTitle: title, dueDate: dueDate)
            return UnfreezePlan(steps: aiSteps, source: .ai, isSuggested: true)
        }
    }
}
