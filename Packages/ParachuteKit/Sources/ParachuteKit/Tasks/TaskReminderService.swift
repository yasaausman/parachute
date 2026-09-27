import Foundation
import SharedKit

/// B5: task due-time reminders + the deadline alarm, through Dev A's `EscalationScheduling`
/// (`.task` → reminders 1 day and 1 hour before, and at `due`, plus the alarm at `due`).
/// Takes plain values so no SwiftData model crosses an actor boundary.
public struct TaskReminderService: Sendable {
    private let scheduler: any EscalationScheduling

    public init(scheduler: any EscalationScheduling) {
        self.scheduler = scheduler
    }

    public func schedule(taskID: UUID, title: String, due: Date) async throws {
        try await scheduler.schedule(itemID: taskID, title: title, due: due, kind: .task)
    }

    /// Call when a task is done or set aside: stops its reminders and alarm.
    public func resolve(taskID: UUID) async {
        await scheduler.resolve(itemID: taskID)
    }

    public func snooze(taskID: UUID, until date: Date) async throws {
        try await scheduler.snooze(itemID: taskID, until: date)
    }
}
