import CoreGraphics
import Foundation

/// A7 capture: text → trial fields. Uses the on-device model when it's there, and never lets it
/// invent anything: every AI field must be backed by the text, or the pattern result wins.
public enum TrialExtractor {
    public static func extract(fromImage image: CGImage, now: Date = .now, knownServices: [String] = [], useAI: Bool = true) async throws -> (text: String, candidate: TrialCandidate) {
        let text = try await TextRecognizer.text(in: image)
        return (text, await extract(fromText: text, now: now, knownServices: knownServices, useAI: useAI))
    }

    public static func extract(fromText text: String, now: Date = .now, knownServices: [String] = [], useAI: Bool = true, calendar: Calendar = .current) async -> TrialCandidate {
        let patterns = PatternExtractor.extract(from: text, now: now, knownServices: knownServices, calendar: calendar)
        guard useAI, AIExtractor.isAvailable,
              let ai = try? await AIExtractor.ask(text, now: now)
        else { return patterns }
        return merge(ai: ai, patterns: patterns, text: text, now: now, calendar: calendar)
    }

    public static func merge(ai: AIExtractor.Answer, patterns: TrialCandidate, text: String, now: Date, calendar: Calendar) -> TrialCandidate {
        var result = patterns
        result.source = .ai

        // Name: a known service in the text beats the model; otherwise take the model's
        // only if those words really appear in the text.
        if patterns.serviceName == nil {
            let name = ai.serviceName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !name.isEmpty, PatternExtractor.normalize(text).contains(PatternExtractor.normalize(name)) {
                result.serviceName = name
            }
        }

        // Price: only an amount that's actually printed in the text.
        let printed = PatternExtractor.amounts(in: text)
        let aiCents = Int((ai.price * 100).rounded())
        if aiCents > 0, let match = printed.first(where: { $0.cents == aiCents }) {
            result.amountCents = match.cents
            result.currencyCode = match.currencyCode
        }

        // Date: the model may pick which printed date is the charge, but only one the text contains.
        if let date = parseDay(ai.chargeDate, calendar: calendar),
           PatternExtractor.candidateDays(in: text, now: now, calendar: calendar).contains(date) {
            result.chargeDate = date
        }

        result.billedByApple = patterns.billedByApple || (ai.billedByApple && PatternExtractor.looksBilledByApple(text))
        return result
    }

    static func parseDay(_ string: String, calendar: Calendar) -> Date? {
        let parts = string.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }
}
