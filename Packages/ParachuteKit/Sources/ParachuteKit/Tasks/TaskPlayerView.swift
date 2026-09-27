import SharedKit
import SwiftData
import SwiftUI

/// Plays (or resumes) a saved `FrozenTask` and records the outcome:
/// done → status, ledger ("+1 task unfrozen"), reminders resolved; snooze → one nudge later;
/// step away → stays active, reminders stay on. Nothing is ever marked "failed".
public struct TaskPlayerView: View {
    let task: FrozenTask
    let onClose: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.parachute) private var services

    public init(task: FrozenTask, onClose: @escaping () -> Void) {
        self.task = task
        self.onClose = onClose
    }

    public var body: some View {
        UnfreezeView(
            plan: TaskStore.plan(for: task),
            goal: task.title,
            startAt: TaskStore.nextIndex(task),
            win: .task(title: task.title),
            onProgress: { steps, next in
                TaskStore.sync(task, steps: steps, nextIndex: next, in: context)
            },
            onFinish: finish
        )
    }

    private func finish(_ outcome: UnfreezeOutcome) {
        let id = task.id
        let title = task.title
        let services = services
        switch outcome {
        case .completed:
            TaskStore.setStatus(.done, for: task, in: context)
            Task {
                await services.ledger.record(kind: .taskDone, title: title, amountCents: nil)
                await services.reminders?.resolve(taskID: id)
            }
        case .snoozed(let until):
            Task { try? await services.reminders?.snooze(taskID: id, until: until) }
        case .gaveUp:
            break
        }
        onClose()
    }
}
