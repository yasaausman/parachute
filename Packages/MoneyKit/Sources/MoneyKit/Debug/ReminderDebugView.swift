import SharedKit
import SwiftData
import SwiftUI
import UserNotifications

/// A2 test bench: time travel + what's actually scheduled.
struct ReminderDebugView: View {
    @Environment(\.moneyEscalation) private var escalation
    @Query(sort: \MoneyDeadline.dueDate) private var deadlines: [MoneyDeadline]
    @AppStorage(TimeTravel.defaultsKey, store: AppGroup.defaults) private var timeTravel = false
    @State private var pending: [(id: String, title: String, fires: Date?)] = []

    var body: some View {
        List {
            Section {
                Toggle("Time travel: 1 day = 1 minute", isOn: $timeTravel)
                    .onChange(of: timeTravel) { Task { await reschedule() } }
                Button("Reschedule all reminders") { Task { await reschedule() } }
            } footer: {
                Text("With time travel on, a trial due in 7 days gets its 3-day reminder in about 4 minutes and its 1-day reminder in about 6. Lock the phone and wait.")
            }

            Section("Pending (\(pending.count))") {
                if pending.isEmpty {
                    Text("Nothing scheduled").foregroundStyle(.secondary)
                }
                ForEach(pending, id: \.id) { item in
                    VStack(alignment: .leading) {
                        Text(item.title).font(.subheadline)
                        Text(item.fires.map { $0.formatted(date: .abbreviated, time: .standard) } ?? "?")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Reminders (A2)")
        .refreshable { await loadPending() }
        .task { await loadPending() }
    }

    private func reschedule() async {
        await escalation?.resync(deadlines)
        await loadPending()
    }

    private func loadPending() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        pending = requests
            .map { request in
                let fires: Date? = switch request.trigger {
                case let trigger as UNCalendarNotificationTrigger: trigger.nextTriggerDate()
                case let trigger as UNTimeIntervalNotificationTrigger: trigger.nextTriggerDate()
                default: nil
                }
                return (id: request.identifier, title: request.content.title, fires: fires)
            }
            .sorted { ($0.fires ?? .distantFuture) < ($1.fires ?? .distantFuture) }
    }
}

/// The Debug tab: every Dev A test bench in one place.
public struct MoneyDebugMenu: View {
    public init() {}

    public var body: some View {
        List {
            NavigationLink("Platform spike (A0)") { PlatformSpikeView() }
            NavigationLink("Reminders + time travel (A2)") { ReminderDebugView() }
        }
        .navigationTitle("Debug")
    }
}
