import Foundation

/// What capture found on a screenshot or in shared text. Every field can be missing: the
/// share sheet shows a pre-filled form either way (CLAUDE.md rule 3).
public struct TrialCandidate: Sendable, Hashable, Codable {
    public enum Source: String, Sendable, Codable {
        /// Apple's on-device model, checked against the text.
        case ai
        /// Plain pattern matching (no Apple Intelligence, or the model failed).
        case patterns
    }

    public var serviceName: String?
    public var amountCents: Int?
    public var currencyCode: String
    /// The day of the first charge (start of day, local time).
    public var chargeDate: Date?
    public var billedByApple: Bool
    public var source: Source

    public init(serviceName: String? = nil, amountCents: Int? = nil, currencyCode: String = "USD", chargeDate: Date? = nil, billedByApple: Bool = false, source: Source = .patterns) {
        self.serviceName = serviceName
        self.amountCents = amountCents
        self.currencyCode = currencyCode
        self.chargeDate = chargeDate
        self.billedByApple = billedByApple
        self.source = source
    }

    /// Everything the "Track it?" card needs for a one-tap save.
    public var isComplete: Bool {
        serviceName?.isEmpty == false && (amountCents ?? 0) > 0 && chargeDate != nil
    }
}
