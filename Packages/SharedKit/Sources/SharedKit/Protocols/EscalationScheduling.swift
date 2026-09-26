import Foundation

/// Implemented by Dev A (MoneyKit). Used by A and B (task reminders).
public protocol EscalationScheduling: Sendable {
    /// Reminders at −3d, −1d, then the final-day alarm at `due`.
    func schedule(itemID: UUID, title: String, due: Date, kind: EscalationKind) async throws
    func snooze(itemID: UUID, until: Date) async throws
    /// Call when a decision is recorded: stops all reminders and the alarm.
    func resolve(itemID: UUID) async
}

public enum EscalationKind: Sendable, Hashable {
    case money(amountCents: Int)
    case task
}
