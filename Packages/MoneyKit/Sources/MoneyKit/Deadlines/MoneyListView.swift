import SharedKit
import SwiftData
import SwiftUI

/// A1: the Money tab. Open trials sorted by charge date with countdowns; decided ones below.
public struct MoneyListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.moneyEscalation) private var escalation
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
                Button("Add trial", systemImage: "plus") { isAdding = true }
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
                Text("Add a free trial and Parachute will count down to the charge.")
            } actions: {
                Button("Add a trial") { isAdding = true }
                    .buttonStyle(.borderedProminent)
            }
        } else {
            List {
                if !open.isEmpty {
                    Section("Coming up") {
                        ForEach(open) { deadline in
                            row(deadline, now: now)
                        }
                        .onDelete { delete(open, at: $0) }
                    }
                }
                if !done.isEmpty {
                    Section("Decided") {
                        ForEach(done) { deadline in
                            row(deadline, now: now)
                        }
                        .onDelete { delete(done, at: $0) }
                    }
                }
            }
        }
    }

    private func row(_ deadline: MoneyDeadline, now: Date) -> some View {
        Button {
            editing = deadline
        } label: {
            DeadlineRow(deadline: deadline, now: now)
        }
        .tint(.primary)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DeadlineMath.summary(
                serviceName: deadline.serviceName,
                amountCents: deadline.amountCents,
                currencyCode: deadline.currencyCode,
                due: deadline.dueDate,
                now: now
            ))
            .font(.headline)
            .foregroundStyle(deadline.isOpen && daysToAct <= 1 ? Theme.accent : .primary)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    private var detail: String {
        let charge = deadline.dueDate.formatted(.dateTime.month(.abbreviated).day())
        switch deadline.status {
        case .cancelled: return "Cancelled before the charge"
        case .kept: return "Kept"
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
