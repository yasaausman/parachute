import Foundation
import SharedKit
import SwiftData

/// Persists task-path progress so the list, the widget ("Essay · Step 3 of 7"), and the scoreboard agree.
@MainActor
enum TaskStore {
    static func create(title: String, dueDate: Date?, plan: UnfreezePlan, in context: ModelContext) -> FrozenTask {
        let task = FrozenTask(title: title, dueDate: dueDate)
        context.insert(task)
        task.steps = microSteps(plan.steps, source: plan.source, doneBefore: 0)
        save(context)
        return task
    }

    static func orderedSteps(_ task: FrozenTask) -> [MicroStep] {
        task.steps.sorted { $0.order < $1.order }
    }

    static func plan(for task: FrozenTask) -> UnfreezePlan {
        let steps = orderedSteps(task)
        let source = steps.first?.source ?? .ai
        return UnfreezePlan(
            steps: steps.map { PlanStep(text: $0.text, seconds: $0.seconds) },
            source: source,
            isSuggested: source == .ai
        )
    }

    /// Index of the first undone step (== count when everything is done).
    static func nextIndex(_ task: FrozenTask) -> Int {
        orderedSteps(task).firstIndex { $0.doneAt == nil } ?? task.steps.count
    }

    /// Mirrors the player's steps (which "Break it smaller" may have re-split) and marks everything before `nextIndex` done.
    static func sync(_ task: FrozenTask, steps: [PlanStep], nextIndex: Int, in context: ModelContext) {
        let old = orderedSteps(task)
        if old.map(\.text) == steps.map(\.text) {
            for (i, step) in old.enumerated() where i < nextIndex && step.doneAt == nil {
                step.doneAt = .now
            }
        } else {
            let source = old.first?.source ?? .ai
            old.forEach(context.delete)
            task.steps = microSteps(steps, source: source, doneBefore: nextIndex)
        }
        save(context)
    }

    static func setStatus(_ status: TaskStatus, for task: FrozenTask, in context: ModelContext) {
        task.status = status
        if status == .done {
            for step in task.steps where step.doneAt == nil { step.doneAt = .now }
        }
        save(context)
    }

    private static func microSteps(_ steps: [PlanStep], source: StepSource, doneBefore: Int) -> [MicroStep] {
        steps.enumerated().map { i, step in
            MicroStep(order: i, text: step.text, seconds: step.seconds, source: source, doneAt: i < doneBefore ? .now : nil)
        }
    }

    private static func save(_ context: ModelContext) {
        try? context.save()
        WidgetRefresh.now()
    }
}
