import Foundation
import SharedKit

/// Cleans model output before it reaches the player. AI steps must never carry URLs
/// (CLAUDE.md rule 9), must stay within 90 seconds, and must not be empty.
public enum StepSanitizer {
    public static let maxSeconds = 90
    public static let minSeconds = 5

    /// Drops empty steps, strips anything that looks like a link, clamps seconds, and drops duplicates.
    public static func sanitizeAI(_ steps: [PlanStep]) -> [PlanStep] {
        var seen = Set<String>()
        var result: [PlanStep] = []
        for step in steps {
            let text = stripLinks(from: step.text)
            guard !text.isEmpty, seen.insert(text.lowercased()).inserted else { continue }
            result.append(PlanStep(text: text, seconds: clampSeconds(step.seconds), url: nil))
        }
        return result
    }

    public static func clampSeconds(_ seconds: Int) -> Int {
        min(max(seconds, minSeconds), maxSeconds)
    }

    /// Removes URLs and bare domains ("hulu.com/account") so the model can't send anyone to an invented page.
    static func stripLinks(from text: String) -> String {
        var output = text
        // Scheme URLs and www. links.
        output = output.replacingOccurrences(
            of: #"(?i)\b(?:https?://|www\.)\S+"#, with: "", options: .regularExpression)
        // Bare domains with an optional path, e.g. "netflix.com/cancelplan".
        output = output.replacingOccurrences(
            of: #"(?i)\b[a-z0-9-]+(?:\.[a-z0-9-]+)*\.(?:com|net|org|io|ai|app|co|tv|me|us|uk)\b(?:/\S*)?"#,
            with: "", options: .regularExpression)
        // Tidy what's left: doubled spaces, a space before punctuation, empty quotes/parentheses.
        output = output.replacingOccurrences(of: #"\(\s*\)|'\s*'|"\s*""#, with: "", options: .regularExpression)
        output = output.replacingOccurrences(of: #"\s+([.,;:!?])"#, with: "$1", options: .regularExpression)
        output = output.replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Plan edits the player makes while running.
public enum PlanEditing {
    /// "Break it smaller": replaces the step at `index` with `smaller`. An empty `smaller` leaves the plan alone.
    public static func replace(stepAt index: Int, in steps: [PlanStep], with smaller: [PlanStep]) -> [PlanStep] {
        guard steps.indices.contains(index), !smaller.isEmpty else { return steps }
        var result = steps
        result.replaceSubrange(index...index, with: smaller)
        return result
    }
}
