import Foundation
import SharedKit
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Turns a task, an unknown service, or one too-big step into tiny steps.
/// Every method returns steps; when the model is unavailable or fails, the result is a non-AI fallback.
public protocol StepAtomizing: Sendable {
    /// False on devices without Apple Intelligence (or with it turned off); the engine then serves templates.
    var isModelAvailable: Bool { get }
    func atomize(taskTitle: String, dueDate: Date?) async -> [PlanStep]
    func atomizeCancel(serviceName: String) async -> [PlanStep]
    func breakSmaller(_ step: PlanStep, goal: String) async -> [PlanStep]
}

#if canImport(FoundationModels)
@Generable
struct AtomizedSteps {
    @Guide(description: "The tiny steps, in order. The first one takes about 10 seconds.", .maximumCount(8))
    var steps: [AtomizedStep]
}

@Generable
struct AtomizedStep {
    @Guide(description: "One physical action that starts with a verb, e.g. 'Open a blank doc. Type your name.' No links or web addresses.")
    var text: String
    @Guide(description: "Seconds it takes, from 5 to 90.", .range(5...90))
    var seconds: Int
}
#endif

/// On-device Foundation Models atomizer (B0/B4). Needs an Apple Intelligence device (CLAUDE.md rule 3).
public struct AIAtomizer: StepAtomizing {
    public init() {}

    public var isModelAvailable: Bool {
        #if canImport(FoundationModels)
        return SystemLanguageModel.default.isAvailable
        #else
        return false
        #endif
    }

    static let instructions = """
        You help people with ADHD start things they're frozen on. You break work into tiny, \
        physical steps a person can do right now. Every step starts with a verb and takes 90 seconds \
        or less. Never say "think about", "consider", or "plan". Never include links, URLs, or web addresses. \
        Be warm and plain. No shame, no pressure.
        """

    public func atomize(taskTitle: String, dueDate: Date?) async -> [PlanStep] {
        await modelSteps(forTask: taskTitle, dueDate: dueDate) ?? Fallbacks.task(taskTitle)
    }

    public func atomizeCancel(serviceName: String) async -> [PlanStep] {
        await modelSteps(forCancel: serviceName) ?? Fallbacks.cancel(serviceName)
    }

    /// Model output only (nil = unavailable or failed). The B0 spike uses these to tell model lists from fallbacks.
    public func modelSteps(forTask taskTitle: String, dueDate: Date?) async -> [PlanStep]? {
        let due = dueDate.map { " It's due \($0.formatted(date: .abbreviated, time: .shortened))." } ?? ""
        let prompt = """
            Break this task into 4 to 8 tiny steps: "\(taskTitle)".\(due)
            The first step must be almost silly-small, like "Open a blank doc. Type your name at the top."
            """
        return await generate(prompt)
    }

    public func modelSteps(forCancel serviceName: String) async -> [PlanStep]? {
        let prompt = """
            Give 3 to 6 tiny steps to cancel a "\(serviceName)" subscription or free trial.
            Say "open the \(serviceName) website" or "open the \(serviceName) app" instead of giving any address.
            The last step is taking a screenshot of the confirmation.
            """
        return await generate(prompt)
    }

    public func breakSmaller(_ step: PlanStep, goal: String) async -> [PlanStep] {
        let prompt = """
            Someone working on "\(goal)" is stuck on this step: "\(step.text)".
            Split just this step into 2 to 4 even smaller steps. The first one takes about 5 seconds.
            """
        return await generate(prompt) ?? Fallbacks.smaller(step)
    }

    private func generate(_ prompt: String) async -> [PlanStep]? {
        #if canImport(FoundationModels)
        guard isModelAvailable else { return nil }
        do {
            let session = LanguageModelSession(instructions: Self.instructions)
            let response = try await session.respond(to: prompt, generating: AtomizedSteps.self)
            let steps = StepSanitizer.sanitizeAI(
                response.content.steps.map { PlanStep(text: $0.text, seconds: $0.seconds) })
            return steps.isEmpty ? nil : steps
        } catch {
            return nil
        }
        #else
        return nil
        #endif
    }
}

/// Non-AI steps for devices without Apple Intelligence. Concrete, never invents a URL.
public enum Fallbacks {
    public static func task(_ title: String) -> [PlanStep] {
        [
            PlanStep(text: "Sit where you'll work. Put your phone face down after this step.", seconds: 15),
            PlanStep(text: "Open whatever you need for \"\(title)\". Just open it.", seconds: 20),
            PlanStep(text: "Write one messy sentence about what done looks like.", seconds: 45),
            PlanStep(text: "Write the three smallest parts of it as a list.", seconds: 60),
            PlanStep(text: "Do the first part for 90 seconds. Stopping after is allowed.", seconds: 90),
        ]
    }

    public static func cancel(_ serviceName: String) -> [PlanStep] {
        [
            PlanStep(text: "Open the \(serviceName) app or website. Log in if it asks.", seconds: 45),
            PlanStep(text: "Find Account, Settings, or your profile picture. Tap it.", seconds: 30),
            PlanStep(text: "Look for Subscription, Membership, Plan, or Billing. Tap it.", seconds: 30),
            PlanStep(text: "Tap Cancel. Say no to any offers until it's confirmed.", seconds: 45),
            PlanStep(text: "Take a screenshot of the confirmation.", seconds: 10),
        ]
    }

    public static func smaller(_ step: PlanStep) -> [PlanStep] {
        [
            PlanStep(text: "Take one slow breath. Read the step once.", seconds: 10),
            PlanStep(text: "Do only the very first action of it: \(step.text)", seconds: StepSanitizer.clampSeconds(step.seconds / 2)),
            PlanStep(text: "Now finish the rest of that step.", seconds: StepSanitizer.clampSeconds(step.seconds)),
        ]
    }
}
