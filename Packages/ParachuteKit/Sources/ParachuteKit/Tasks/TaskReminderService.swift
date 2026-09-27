import Foundation
import SharedKit

public struct TaskReminderService: Sendable {
    private let scheduler: any EscalationScheduling
    
    public init(scheduler: any EscalationScheduling) {
        self.scheduler = scheduler
    }
    
    /// Schedule reminders for a frozen task that has a due date.
    public func scheduleReminders(for task: FrozenTask) async throws {
        guard let dueDate = task.dueDate else { return }
        try await scheduler.schedule(
            itemID: task.id,
            title: task.title,
            due: dueDate,
            kind: .task
        )
    }
    
    /// Cancel reminders when a task is completed or abandoned.
    public func cancelReminders(for task: FrozenTask) async {
        await scheduler.resolve(itemID: task.id)
    }
    
    /// Snooze a task's reminders.
    public func snooze(task: FrozenTask, until date: Date) async throws {
        try await scheduler.snooze(itemID: task.id, until: date)
    }
}
