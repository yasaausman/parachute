import Foundation
import SharedKit

/// B3: picks where a plan comes from.
///
/// Cancel: curated (`CancelSteps.json`) → Apple's subscription settings → AI "Suggested steps" → non-AI template.
/// Apple-billed trials skip web curated steps: those only work for web signups (CLAUDE.md rule 8).
/// Task: AI atomizer → non-AI template.
public actor UnfreezeEngine: UnfreezeProviding {
    private let loader: CancelStepsLoader
    private let atomizer: any StepAtomizing

    public init(loader: CancelStepsLoader = CancelStepsLoader(), atomizer: any StepAtomizing = AIAtomizer()) {
        self.loader = loader
        self.atomizer = atomizer
    }

    public func plan(for request: UnfreezeRequest) async throws -> UnfreezePlan {
        switch request {
        case .cancel(let serviceID, let serviceName, let billedByApple):
            var curated: CancelStepsFile.Service?
            if let serviceID { curated = await loader.service(id: serviceID) }
            if curated == nil { curated = await loader.service(named: serviceName) }

            if let curated, !billedByApple || curated.isAppleBilled {
                return curated.plan
            }
            if billedByApple {
                return UnfreezePlan(steps: AppleSubscriptions.steps(serviceName: serviceName), source: .appleSubscriptions, isSuggested: false)
            }
            return UnfreezePlan(steps: await atomizer.atomizeCancel(serviceName: serviceName), source: .ai, isSuggested: true)

        case .task(let title, let dueDate):
            return UnfreezePlan(steps: await atomizer.atomize(taskTitle: title, dueDate: dueDate), source: .ai, isSuggested: true)
        }
    }

    /// "Break it smaller" for the step someone is stuck on.
    public func smallerSteps(for step: PlanStep, goal: String) async -> [PlanStep] {
        await atomizer.breakSmaller(step, goal: goal)
    }
}

extension UnfreezeRequest {
    /// What the person is trying to get done, for "Break it smaller".
    public var goal: String {
        switch self {
        case .cancel(_, let serviceName, _): "Cancel \(serviceName)"
        case .task(let title, _): title
        }
    }
}
