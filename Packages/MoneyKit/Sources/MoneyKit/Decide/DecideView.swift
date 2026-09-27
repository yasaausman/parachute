import SharedKit
import SwiftData
import SwiftUI

/// A4 minimum: record a decision so the alarm chain ends. A5 adds Snooze-until, "I'm frozen",
/// the ledger write, and the final design.
public struct DecideView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.moneyEscalation) private var escalation
    @Query private var matches: [MoneyDeadline]

    private let itemID: UUID

    public init(itemID: UUID) {
        self.itemID = itemID
        _matches = Query(filter: #Predicate<MoneyDeadline> { $0.id == itemID })
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let deadline = matches.first {
                    content(deadline)
                } else {
                    ContentUnavailableView("This trial is gone", systemImage: "questionmark.circle", description: Text("It may have been deleted. Nothing will ring for it."))
                        .task { await escalation?.resolve(itemID: itemID) }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Later") { dismiss() }
                }
            }
        }
    }

    private func content(_ deadline: MoneyDeadline) -> some View {
        VStack(spacing: Theme.spacing * 1.5) {
            Spacer()
            Text(DeadlineMath.summary(
                serviceName: deadline.serviceName,
                amountCents: deadline.amountCents,
                currencyCode: deadline.currencyCode,
                due: deadline.dueDate,
                now: .now
            ))
            .font(.title.bold())
            .multilineTextAlignment(.center)

            Text("What do you want to do?")
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                record(.cancelled, for: deadline)
            } label: {
                Label("I cancelled it", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                record(.kept, for: deadline)
            } label: {
                Label("Keep it", systemImage: "hand.thumbsup")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
    }

    private func record(_ status: DeadlineStatus, for deadline: MoneyDeadline) {
        deadline.status = status
        try? context.save()
        let id = deadline.id
        Task { await escalation?.resolve(itemID: id) }
        dismiss()
    }
}
