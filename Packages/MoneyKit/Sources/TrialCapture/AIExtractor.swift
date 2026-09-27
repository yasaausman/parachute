import Foundation
import FoundationModels

/// Apple's on-device model (Foundation Models). Needs an Apple Intelligence device
/// (CLAUDE.md rule 3); callers fall back to `PatternExtractor`.
public enum AIExtractor {
    @Generable(description: "A free trial or subscription found in a screenshot or message")
    struct ExtractedTrial {
        @Guide(description: "The product being subscribed to, e.g. Spotify, Hulu, Apple One, Google AI Pro. Never the app store, the bank, or the payment card. Empty if unclear.")
        var serviceName: String

        @Guide(description: "The recurring price charged after the free trial, as a plain number like 6.99. 0 if no price is shown.")
        var price: Double

        @Guide(description: "The date of the first charge or renewal, as YYYY-MM-DD. Empty if no date is shown.")
        var chargeDate: String

        @Guide(description: "true only if it is bought through Apple: mentions Apple Account, App Store, or Confirm with Side Button.")
        var billedByApple: Bool
    }

    /// The model's answer as plain values (so the fact-check in `TrialExtractor.merge` is testable).
    public struct Answer: Sendable, Hashable {
        public var serviceName: String
        public var price: Double
        public var chargeDate: String
        public var billedByApple: Bool

        public init(serviceName: String, price: Double, chargeDate: String, billedByApple: Bool) {
            self.serviceName = serviceName
            self.price = price
            self.chargeDate = chargeDate
            self.billedByApple = billedByApple
        }
    }

    public static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    /// For the eval tool: the model's raw answer, or the error it threw.
    public static func debugDescription(for text: String, now: Date) async -> String {
        do {
            let answer = try await ask(text, now: now)
            return "name=\(answer.serviceName) price=\(answer.price) date=\(answer.chargeDate) apple=\(answer.billedByApple)"
        } catch {
            return "error: \(error)"
        }
    }

    static func ask(_ text: String, now: Date) async throws -> Answer {
        let session = LanguageModelSession(instructions: """
            You read text copied from a screenshot of a subscription or free-trial screen and \
            pull out the facts. Only use what the text says. Never guess a price or a date.
            """)
        let today = now.formatted(.iso8601.year().month().day())
        let prompt = "Today is \(today).\n\nText:\n\(text.prefix(3000))"
        let trial = try await session.respond(to: prompt, generating: ExtractedTrial.self, options: GenerationOptions(samplingMode: .greedy)).content
        return Answer(serviceName: trial.serviceName, price: trial.price, chargeDate: trial.chargeDate, billedByApple: trial.billedByApple)
    }
}
