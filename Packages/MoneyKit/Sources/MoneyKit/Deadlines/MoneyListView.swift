import SharedKit
import SwiftData
import SwiftUI

/// A1: the Money tab. Open trials sorted by charge date with countdowns; decided ones below.
public struct MoneyListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.moneyEscalation) private var escalation
    @Environment(\.proEntitlements) private var pro
    @Query(sort: \MoneyDeadline.dueDate) private var deadlines: [MoneyDeadline]
    @State private var editing: MoneyDeadline?
    @State private var isAdding = false

    public init() {}

    public var body: some View {
        TimelineView(.everyMinute) { timeline in
            content(now: timeline.date)
        }
        .navigationTitle("Money")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add trial", systemImage: "plus") { add() }
            }
        }
        .task {
            await escalation?.resync(deadlines)
        }
        .sheet(isPresented: $isAdding) {
            NavigationStack { DeadlineEditorView() }
        }
        .sheet(item: $editing) { deadline in
            NavigationStack { DeadlineEditorView(deadline: deadline) }
        }
    }

    @ViewBuilder
    private func content(now: Date) -> some View {
        let open = deadlines.filter(\.isOpen)
        let done = deadlines.filter { !$0.isOpen }.sorted { $0.dueDate > $1.dueDate }

        if deadlines.isEmpty {
            ContentUnavailableView {
                Label("No trials yet", systemImage: "dollarsign.circle")
            } description: {
                Text("Add a free trial and Untax will count down to the charge, then help you get out in time.")
            } actions: {
                Button("Add a trial") { add() }
                    .buttonStyle(.untax)
                    .padding(.horizontal, Theme.screenPadding)
            }
            .untaxScreen()
        } else {
            List {
                if !open.isEmpty {
                    Section {
                        ForEach(open) { deadline in
                            row(deadline, now: now)
                        }
                        .onDelete { delete(open, at: $0) }
                    } header: {
                        Text("Coming up")
                            .font(Theme.headline(.subheadline))
                            .foregroundStyle(Theme.inkMuted)
                            .textCase(nil)
                    } footer: {
                        if let pro, !pro.isProNow {
                            Button("Reminders are on. The final-day alarm that keeps coming back is Pro. See Pro") {
                                pro.presentPaywall()
                            }
                            .font(.footnote)
                            .foregroundStyle(Theme.accentText)
                        }
                    }
                }
                if !done.isEmpty {
                    Section {
                        ForEach(done) { deadline in
                            row(deadline, now: now)
                        }
                        .onDelete { delete(done, at: $0) }
                    } header: {
                        Text("Decided")
                            .font(Theme.headline(.subheadline))
                            .foregroundStyle(Theme.inkMuted)
                            .textCase(nil)
                    }
                }
            }
            .listRowBackground(Theme.surface)
            .untaxScreen()
        }
    }

    /// Open trials: tap to decide (the main job). Decided ones: tap to edit or reopen.
    private func row(_ deadline: MoneyDeadline, now: Date) -> some View {
        Button {
            if deadline.isOpen {
                DecideRouter.shared.request(itemID: deadline.id)
            } else {
                editing = deadline
            }
        } label: {
            DeadlineRow(deadline: deadline, now: now)
        }
        .tint(Theme.ink)
        .accessibilityHint(deadline.isOpen ? "Opens Decide: cancel, keep, snooze, or get help" : "Edit or reopen")
        .accessibilityAction(named: "Edit") { editing = deadline }
        .swipeActions(edge: .leading) {
            Button("Edit", systemImage: "pencil") { editing = deadline }
                .tint(Theme.inkMuted)
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil") { editing = deadline }
            if deadline.isOpen {
                Button("Decide", systemImage: "arrow.up.forward.app") { DecideRouter.shared.request(itemID: deadline.id) }
            }
        }
    }

    /// Free users can track `ProFeatures.freeTrialLimit` open trials; the next one shows the paywall.
    private func add() {
        let openCount = deadlines.filter(\.isOpen).count
        if let pro, !pro.isProNow, openCount >= ProFeatures.freeTrialLimit {
            pro.presentPaywall()
        } else {
            isAdding = true
        }
    }

    private func delete(_ list: [MoneyDeadline], at offsets: IndexSet) {
        for index in offsets {
            let id = list[index].id
            context.delete(list[index])
            Task { await escalation?.resolve(itemID: id) }
        }
        try? context.save()
    }
}

struct DeadlineRow: View {
    let deadline: MoneyDeadline
    let now: Date

    /// Days left to act: for Apple-billed items that's the day before the charge.
    private var daysToAct: Int {
        DeadlineMath.calendarDays(from: now, to: deadline.cancelBy)
    }

    private var isUrgent: Bool { deadline.isOpen && daysToAct <= 1 }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(deadline.serviceName)
                    .font(Theme.headline())
                    .foregroundStyle(deadline.isOpen ? Theme.ink : Theme.inkMuted)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkMuted)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode))
                    .font(Theme.number(.headline))
                    .monospacedDigit()
                    .foregroundStyle(deadline.isOpen ? Theme.ink : Theme.inkMuted)
                if deadline.isOpen {
                    Text(DeadlineMath.countdownText(days: DeadlineMath.calendarDays(from: now, to: deadline.dueDate)))
                        .font(Theme.number(.subheadline))
                        .monospacedDigit()
                        .foregroundStyle(isUrgent ? Theme.urgentText : Theme.inkMuted)
                }
            }
        }
        .padding(.vertical, 6)
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(headline). \(detail)")
    }

    /// Open: the countdown. Decided: just the service and amount; the countdown no longer matters.
    private var headline: String {
        guard deadline.isOpen else {
            return "\(deadline.serviceName) · \(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode))"
        }
        return DeadlineMath.summary(
            serviceName: deadline.serviceName,
            amountCents: deadline.amountCents,
            currencyCode: deadline.currencyCode,
            due: deadline.dueDate,
            now: now
        )
    }

    private var detail: String {
        let charge = deadline.dueDate.formatted(.dateTime.month(.abbreviated).day())
        switch deadline.status {
        case .cancelled:
            // Only claim the money while the charge is still ahead; the ledger keeps the real record.
            guard DeadlineDecision.beforeCharge(deadline.dueDate, now: now) else { return "Cancelled" }
            return "Cancelled · \(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode)) won't be charged"
        case .kept: return "Kept"
        case .snoozed where (deadline.snoozedUntil ?? .distantPast) > now:
            return "Snoozed until \(deadline.snoozedUntil!.formatted(date: .omitted, time: .shortened))"
        case .snoozed, .tracking:
            guard deadline.billedByApple else { return "Charges \(charge)" }
            let cancelBy = deadline.cancelBy.formatted(.dateTime.month(.abbreviated).day())
            return "Charges \(charge) · cancel by \(cancelBy) (Apple needs a day)"
        }
    }
}

#Preview {
    NavigationStack { MoneyListView() }
        .modelContainer(MoneyPreview.container)
}

@MainActor
enum MoneyPreview {
    static let container: ModelContainer = {
        let container = try! SharedStore.makeContainer(inMemory: true)
        let day: TimeInterval = 24 * 60 * 60
        container.mainContext.insert(MoneyDeadline(serviceName: "Spotify", serviceID: "spotify", amountCents: 699, dueDate: .now.addingTimeInterval(3 * day), billedByApple: false))
        container.mainContext.insert(MoneyDeadline(serviceName: "Apple One", serviceID: "apple-one", amountCents: 2195, dueDate: .now.addingTimeInterval(day), billedByApple: true))
        container.mainContext.insert(MoneyDeadline(serviceName: "Claude", serviceID: "claude", amountCents: 2000, dueDate: .now.addingTimeInterval(-2 * day), billedByApple: false, status: .cancelled))
        return container
    }()
}
