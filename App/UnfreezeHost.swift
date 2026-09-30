import MoneyKit
import ParachuteKit
import SharedKit
import SwiftData
import SwiftUI

/// Decide → 🧊 "Get unstuck": plays B's `UnfreezeFlowView`, then records the money decision the
/// same way the Decide screen does (`DeadlineDecision`).
struct UnfreezeHost: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let request: UnfreezeRequest
    let itemID: UUID?

    private var deadline: MoneyDeadline? {
        guard let itemID else { return nil }
        return try? context.fetch(FetchDescriptor<MoneyDeadline>(predicate: #Predicate { $0.id == itemID })).first
    }

    var body: some View {
        UnfreezeFlowView(request: request, win: deadline.map { .money(cents: $0.amountCents) }, onFinish: finish)
    }

    private func finish(_ outcome: UnfreezeOutcome) {
        Task {
            if let deadline {
                switch outcome {
                case .completed:
                    await DeadlineDecision.cancelled.apply(to: deadline, context: context, escalation: dependencies.escalation, ledger: dependencies.ledger)
                case .snoozed(let until):
                    await DeadlineDecision.snoozed(until: until).apply(to: deadline, context: context, escalation: dependencies.escalation, ledger: dependencies.ledger)
                case .gaveUp:
                    break
                }
            }
            dismiss()
        }
    }
}
