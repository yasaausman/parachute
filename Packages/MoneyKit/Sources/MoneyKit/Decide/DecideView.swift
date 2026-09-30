import SharedKit
import SwiftData
import SwiftUI

/// A5: the Decide screen. Opened by the alarm's Decide button, a reminder tap, or a trial row.
/// Cancel · Get unstuck · Keep · Snooze. Never imports ParachuteKit: "Get unstuck" is a closure.
public struct DecideView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.moneyEscalation) private var escalation
    @Environment(\.completionLedger) private var ledger
    @Query private var matches: [MoneyDeadline]
    @State private var path: [Step] = []

    private let itemID: UUID
    private let onFrozen: (UnfreezeRequest) -> Void

    enum Step: Hashable {
        case cancelSteps
        case snooze
    }

    public init(itemID: UUID, onFrozen: @escaping (UnfreezeRequest) -> Void) {
        self.itemID = itemID
        self.onFrozen = onFrozen
        _matches = Query(filter: #Predicate<MoneyDeadline> { $0.id == itemID })
    }

    public var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let deadline = matches.first {
                    choices(for: deadline)
                        .navigationDestination(for: Step.self) { step in
                            switch step {
                            case .cancelSteps:
                                CancelStepsView(deadline: deadline, onDone: { decide(.cancelled, deadline) }, onFrozen: { frozen(deadline) })
                            case .snooze:
                                SnoozeView(deadline: deadline) { until in decide(.snoozed(until: until), deadline) }
                            }
                        }
                } else {
                    ContentUnavailableView("This trial is gone", systemImage: "questionmark.circle", description: Text("It may have been deleted. Nothing will ring for it."))
                        .task { await escalation?.resolve(itemID: itemID) }
                        .untaxScreen()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
        }
        .tint(Theme.accentText)
    }

    private func choices(for deadline: MoneyDeadline) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                header(deadline)
                    .padding(.top, Theme.spacing)
                    .padding(.bottom, Theme.spacing * 1.5)

                Button { path.append(.cancelSteps) } label: {
                    Label("Cancel it", systemImage: "xmark.circle.fill")
                }
                .buttonStyle(.untax)
                .accessibilityHint("See the exact steps, then mark it done")

                Button { decide(.kept, deadline) } label: {
                    Label("Keep it", systemImage: "hand.thumbsup.fill")
                }
                .buttonStyle(.untaxQuiet)
                .accessibilityHint("Stop reminding me. I want this one.")

                Button { path.append(.snooze) } label: {
                    Label("Snooze", systemImage: "moon.zzz.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Remind me a bit later")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Frozen? Totally normal. One tiny step at a time, and the first one is free.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.inkMuted)
                    Button { frozen(deadline) } label: {
                        Label("Get unstuck", systemImage: "snowflake")
                    }
                    .buttonStyle(.untaxFrozen)
                    .accessibilityHint("One tiny step at a time. The first one is free.")
                }
                .padding(.top, Theme.spacing)
            }
            .padding(Theme.screenPadding)
        }
        .untaxScreen()
    }

    private func header(_ deadline: MoneyDeadline) -> some View {
        let days = DeadlineMath.calendarDays(from: .now, to: deadline.dueDate)
        return VStack(alignment: .leading, spacing: 12) {
            Text(titleLine(deadline, days: days))
                .font(Theme.display())
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode))
                    .font(Theme.number(.largeTitle))
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink)
                Text(DeadlineMath.countdownText(days: days))
                    .font(Theme.number(.title3))
                    .monospacedDigit()
                    .foregroundStyle(days <= 1 ? Theme.urgentText : Theme.accentText)
            }
            if deadline.billedByApple {
                Text("Billed by Apple: cancel by \(deadline.cancelBy.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())).")
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    /// "Netflix bills you tomorrow." Warm and plain, never a warning.
    private func titleLine(_ deadline: MoneyDeadline, days: Int) -> String {
        switch days {
        case ..<0: "\(deadline.serviceName) \(DeadlineMath.countdownText(days: days))."
        default: "\(deadline.serviceName) bills you \(DeadlineMath.countdownText(days: days))."
        }
    }

    private func decide(_ decision: DeadlineDecision, _ deadline: MoneyDeadline) {
        Task {
            await decision.apply(to: deadline, context: context, escalation: escalation, ledger: ledger)
            dismiss()
        }
    }

    private func frozen(_ deadline: MoneyDeadline) {
        onFrozen(deadline.unfreezeRequest)
    }
}
