import MoneyKit
import SharedKit
import SwiftData
import SwiftUI

/// Gets a plan from the injected `UnfreezeProviding` and plays it. On "completed" for a money
/// item it records the cancellation (ledger + escalation) like the Decide screen does.
struct UnfreezeHost: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var plan: UnfreezePlan?
    @State private var failed = false

    let request: UnfreezeRequest
    let itemID: UUID?

    var body: some View {
        Group {
            if let plan {
                // Swap for ParachuteKit's UnfreezeView(plan:onFinish:) when B1 lands.
                PlaceholderUnfreezePlayer(plan: plan, onFinish: finish)
            } else if failed {
                ContentUnavailableView("Couldn't load steps", systemImage: "exclamationmark.triangle")
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                plan = try await dependencies.unfreeze.plan(for: request)
            } catch {
                failed = true
            }
        }
    }

    private func finish(_ outcome: UnfreezeOutcome) {
        Task {
            if case .completed = outcome, let itemID, let deadline = try? context.fetch(
                FetchDescriptor<MoneyDeadline>(predicate: #Predicate { $0.id == itemID })
            ).first {
                await DeadlineDecision.cancelled.apply(
                    to: deadline, context: context,
                    escalation: dependencies.escalation, ledger: dependencies.ledger
                )
            }
            dismiss()
        }
    }
}

/// Stand-in for B1's player so the hand-off can be tested end to end: all steps in a list.
private struct PlaceholderUnfreezePlayer: View {
    let plan: UnfreezePlan
    let onFinish: (UnfreezeOutcome) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(plan.steps.enumerated()), id: \.offset) { index, step in
                        Label(step.text, systemImage: "\(index + 1).circle")
                    }
                } header: {
                    Text(plan.isSuggested ? "Suggested steps" : "Steps")
                } footer: {
                    Text("Placeholder until Dev B's Unfreeze player (B1).")
                }
                Section {
                    Button("I did it", systemImage: "checkmark.circle.fill") { onFinish(.completed) }
                    Button("I'll come back to it", systemImage: "arrow.uturn.backward") { onFinish(.gaveUp) }
                }
            }
            .navigationTitle("One step at a time")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Theme.frozen)
    }
}
