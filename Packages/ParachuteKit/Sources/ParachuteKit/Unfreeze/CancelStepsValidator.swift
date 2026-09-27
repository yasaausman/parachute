import Foundation
import SharedKit

/// Rules for `CancelSteps.json` (B2). Dev A's content must pass these; the loader drops services that don't.
public enum CancelStepsValidator {
    public struct Issue: Sendable, Hashable, CustomStringConvertible {
        public var serviceID: String
        public var problem: String
        public var description: String { "\(serviceID.isEmpty ? "<no id>" : serviceID): \(problem)" }
    }

    public static func issues(in file: CancelStepsFile) -> [Issue] {
        var issues: [Issue] = []
        var seen = Set<String>()
        for service in file.services {
            issues += self.issues(in: service)
            if !service.id.isEmpty, !seen.insert(service.id).inserted {
                issues.append(Issue(serviceID: service.id, problem: "duplicate id"))
            }
        }
        return issues
    }

    public static func issues(in service: CancelStepsFile.Service) -> [Issue] {
        func issue(_ problem: String) -> Issue { Issue(serviceID: service.id, problem: problem) }
        var issues: [Issue] = []
        if service.id.trimmed.isEmpty { issues.append(issue("empty id")) }
        if service.name.trimmed.isEmpty { issues.append(issue("empty name")) }
        if service.verifiedOn.trimmed.isEmpty { issues.append(issue("not verified (verifiedOn is empty)")) }
        if service.steps.isEmpty { issues.append(issue("no steps")) }
        for (index, step) in service.steps.enumerated() {
            let n = index + 1
            if step.text.trimmed.isEmpty { issues.append(issue("step \(n) has empty text")) }
            if step.seconds <= 0 { issues.append(issue("step \(n) has \(step.seconds)s (must be > 0)")) }
            if step.seconds > StepSanitizer.maxSeconds {
                issues.append(issue("step \(n) is \(step.seconds)s (max \(StepSanitizer.maxSeconds))"))
            }
            if let url = step.url, url.scheme?.lowercased() != "https" {
                issues.append(issue("step \(n) URL must be https"))
            }
        }
        return issues
    }

    public static func isValid(_ service: CancelStepsFile.Service) -> Bool {
        issues(in: service).isEmpty
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
