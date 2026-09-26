import Foundation
import SwiftData

/// A money deadline (a free trial in the sprint). Written by Dev A, read by Dev B (widgets, scoreboard).
@Model
public final class MoneyDeadline {
    public var id: UUID
    /// "Hulu"
    public var serviceName: String
    /// Matches a `CancelSteps.json` service `id` when known.
    public var serviceID: String?
    /// 1799 for $17.99.
    public var amountCents: Int
    /// ISO 4217, e.g. "USD".
    public var currencyCode: String
    /// When the charge happens.
    public var dueDate: Date
    /// True → cancel via Apple's subscription settings (CLAUDE.md rule 8).
    public var billedByApple: Bool
    public var statusRaw: String
    public var snoozedUntil: Date?
    public var createdAt: Date

    public var status: DeadlineStatus {
        get { DeadlineStatus(rawValue: statusRaw) ?? .tracking }
        set { statusRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        serviceName: String,
        serviceID: String? = nil,
        amountCents: Int,
        currencyCode: String = "USD",
        dueDate: Date,
        billedByApple: Bool,
        status: DeadlineStatus = .tracking,
        snoozedUntil: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.serviceName = serviceName
        self.serviceID = serviceID
        self.amountCents = amountCents
        self.currencyCode = currencyCode
        self.dueDate = dueDate
        self.billedByApple = billedByApple
        self.statusRaw = status.rawValue
        self.snoozedUntil = snoozedUntil
        self.createdAt = createdAt
    }
}

public enum DeadlineStatus: String, Codable, Sendable, CaseIterable {
    case tracking, cancelled, kept, snoozed
}
