import Foundation
import SharedKit
#if canImport(FoundationModels)
import FoundationModels
#endif

#if canImport(FoundationModels)
@available(iOS 26, *)
@Generable
struct AtomizedSteps: Sendable {
    /// Each step should be ≤ 90 seconds, verb-first, physically concrete.
    var steps: [AtomizedStep]
}

@available(iOS 26, *)
@Generable
struct AtomizedStep: Sendable {
    /// Verb-first instruction, e.g. "Open a blank doc. Type your name."
    var text: String
    /// Estimated seconds to complete (1–90).
    var seconds: Int
}
#endif

public struct AIAtomizer: Sendable {
    public init() {}

    public func atomize(taskTitle: String, dueDate: Date?) async throws -> [PlanStep] {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            do {
                let session = LanguageModelSession()
                let deadlineNote = dueDate.map { " It's due \($0.formatted(date: .abbreviated, time: .shortened))." } ?? ""
                let prompt = """
                Break down the task '\(taskTitle)' into tiny, concrete steps.\(deadlineNote)

                Rules:
                - Each step MUST take ≤ 90 seconds
                - The FIRST step must be trivially small — something anyone can do in 10 seconds \
                  (e.g. "Open a blank doc. Type your name at the top.")
                - Every step starts with a verb: Open, Write, Click, Type, Read, etc.
                - Steps must be physically concrete — no "think about" or "consider"
                - 4–8 steps total
                """
                let response = try await session.respond(to: prompt, generating: AtomizedSteps.self)
                let steps = response.content.steps.map {
                    PlanStep(text: $0.text, seconds: min(max($0.seconds, 5), 90))
                }
                if !steps.isEmpty { return steps }
            } catch {
                // Fall through to non-AI fallback
            }
        }
        #endif
        return fallbackPlan(for: taskTitle)
    }

    public func atomizeCancel(serviceName: String) async throws -> [PlanStep] {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            do {
                let session = LanguageModelSession()
                let prompt = """
                Give me step-by-step instructions to cancel my '\(serviceName)' subscription or service.

                Rules:
                - Each step MUST take ≤ 90 seconds
                - The first step should be trivially small
                - Every step starts with a verb: Open, Tap, Click, Navigate, etc.
                - Steps must be physically concrete
                - NEVER invent or guess URLs — just say "go to the website" or "open the app"
                - 3–6 steps total
                """
                let response = try await session.respond(to: prompt, generating: AtomizedSteps.self)
                let steps = response.content.steps.map {
                    PlanStep(text: $0.text, seconds: min(max($0.seconds, 5), 90))
                }
                if !steps.isEmpty { return steps }
            } catch {
                // Fall through to non-AI fallback
            }
        }
        #endif
        return fallbackCancel(for: serviceName)
    }

    private func fallbackPlan(for title: String) -> [PlanStep] {
        [
            PlanStep(text: "Sit down and open whatever you need for '\(title)'. That's it.", seconds: 15),
            PlanStep(text: "Write one sentence — any sentence — about what you need to do.", seconds: 30),
            PlanStep(text: "Break '\(title)' into 3 parts. Write them down.", seconds: 60),
            PlanStep(text: "Start the first part. Just the very beginning.", seconds: 90),
        ]
    }

    private func fallbackCancel(for serviceName: String) -> [PlanStep] {
        [
            PlanStep(text: "Open the website or app for \(serviceName).", seconds: 30),
            PlanStep(text: "Log in to your account.", seconds: 45),
            PlanStep(text: "Navigate to account or subscription settings.", seconds: 30),
            PlanStep(text: "Locate the cancel button and confirm cancellation.", seconds: 45),
            PlanStep(text: "Take a screenshot of the confirmation.", seconds: 15),
        ]
    }
}
