import SharedKit
import SwiftData
import SwiftUI

/// A5: the Decide screen. Opened by the alarm's Decide button, a reminder tap, or a trial row.
/// Cancel · I'm frozen · Keep · Snooze. Never imports ParachuteKit: "I'm frozen" is a closure.
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
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
        }
        .tint(Theme.accent)
    }

    private func choices(for deadline: MoneyDeadline) -> some View {
        ScrollView {
            VStack(spacing: Theme.spacing) {
                header(deadline)
                    .padding(.vertical, Theme.spacing)

                ChoiceButton(
                    title: "Cancel it",
                    subtitle: "See the exact steps, then mark it done",
                    systemImage: "xmark.circle.fill",
                    style: .primary
                ) { path.append(.cancelSteps) }

                ChoiceButton(
                    title: "I'm frozen",
                    subtitle: "One tiny step at a time. The first one is free.",
                    systemImage: "snowflake",
                    style: .frozen
                ) { frozen(deadline) }

                ChoiceButton(
                    title: "Keep it",
                    subtitle: "Stop reminding me. I want this one.",
                    systemImage: "hand.thumbsup.fill",
                    style: .plain
                ) { decide(.kept, deadline) }

                ChoiceButton(
                    title: "Snooze",
                    subtitle: "Remind me a bit later",
                    systemImage: "moon.zzz.fill",
                    style: .plain
                ) { path.append(.snooze) }
            }
            .padding()
        }
    }

    private func header(_ deadline: MoneyDeadline) -> some View {
        VStack(spacing: 8) {
            Text(deadline.serviceName)
                .font(.largeTitle.bold())
            Text(chargeLine(deadline))
                .font(.title3)
                .foregroundStyle(Theme.accentText)
            if deadline.billedByApple {
                Text("Billed by Apple: cancel by \(deadline.cancelBy.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
    }

    private func chargeLine(_ deadline: MoneyDeadline) -> String {
        let amount = deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode)
        let days = DeadlineMath.calendarDays(from: .now, to: deadline.dueDate)
        return "\(amount) \(DeadlineMath.countdownText(days: days))"
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

/// A big, calm, full-width choice. ADHD-first: one idea per button, a short "what happens" line.
struct ChoiceButton: View {
    enum Style { case primary, frozen, plain }

    @Environment(\.dynamicTypeSize) private var typeSize

    let title: String
    let subtitle: String
    let systemImage: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // Accessibility text sizes stack the icon above the words so they get the full width.
            let layout = typeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                : AnyLayout(HStackLayout(spacing: Theme.spacing))
            layout {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(minWidth: 32, alignment: .leading)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).opacity(0.8)
                }
                if !typeSize.isAccessibilitySize {
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").font(.footnote.bold()).opacity(0.5)
                        .accessibilityHidden(true)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(foreground)
            .background(background, in: .rect(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
        .accessibilityAddTraits(.isButton)
    }

    private var foreground: Color {
        switch style {
        case .primary: .white
        case .frozen: .primary
        case .plain: .primary
        }
    }

    private var background: Color {
        switch style {
        case .primary: Theme.accentFill
        case .frozen: Theme.frozen.opacity(0.25)
        case .plain: Color(.secondarySystemBackground)
        }
    }
}
