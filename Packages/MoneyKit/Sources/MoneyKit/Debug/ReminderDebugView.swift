#if DEBUG
import AlarmKit
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
    @State private var alarms: [(id: String, state: String, fires: Date?)] = []
    @State private var chains: [AlarmRecord] = []
    @State private var alarmLog: [String] = []

    var body: some View {
        List {
            Section {
                Toggle("Time travel: 1 day = 1 minute", isOn: $timeTravel)
                    .onChange(of: timeTravel) { Task { await reschedule() } }
                Button("Reschedule all reminders") { Task { await reschedule() } }
            } footer: {
                Text("With time travel on, a trial due in 7 days gets its 3-day reminder in about 4 minutes and its 1-day reminder in about 6. Lock the phone and wait.")
            }

            Section {
                if let first = deadlines.first(where: \.isOpen) {
                    Button("Ring \(first.serviceName)'s final alarm in 1 minute") {
                        Task { await ringSoon(first) }
                    }
                }
                ForEach(chains, id: \.itemID) { chain in
                    VStack(alignment: .leading) {
                        Text(chain.title).font(.subheadline)
                        Text("next ring: \(chain.fireDate.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? "?") · rings so far: \(chain.rings)\(chain.isTest == true ? " · test" : "")")
                            .font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                }
                ForEach(alarms, id: \.id) { alarm in
                    Text("\(alarm.id) · \(alarm.state) · \(alarm.fires.map { $0.formatted(date: .omitted, time: .standard) } ?? "-")")
                        .font(.caption.monospaced())
                }
            } header: {
                Text("Final-day alarm (A4)")
            } footer: {
                Text("Lock the phone. When it rings, use Stop: it comes back in 30 minutes (1 minute with time travel on). Tap Decide to open the Decide screen; a decision ends the chain.")
            }

            Section("Alarm log") {
                if alarmLog.isEmpty {
                    Text("Nothing yet").foregroundStyle(.secondary)
                }
                ForEach(Array(alarmLog.enumerated().reversed()), id: \.offset) { _, line in
                    Text(line).font(.caption.monospaced())
                }
            }

            Section("Pending reminders (\(pending.count))") {
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
        .navigationTitle("Reminders + alarm")
        .refreshable { await loadPending() }
        .task {
            // Stop/Decide run as intents outside this screen, so poll instead of waiting for a redraw.
            while !Task.isCancelled {
                await loadPending()
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    private func reschedule() async {
        await escalation?.resync(deadlines)
        await loadPending()
    }

    private func ringSoon(_ deadline: MoneyDeadline) async {
        let title = DeadlineAlarmPlanner.moneyTitle(
            serviceName: deadline.serviceName, amountCents: deadline.amountCents,
            currencyCode: deadline.currencyCode, billedByApple: deadline.billedByApple
        )
        try? await DeadlineAlarms(timeTravel: { false }).ringForTest(itemID: deadline.id, title: title, at: .now.addingTimeInterval(60))
        await loadPending()
    }

    private func loadPending() async {
        chains = DeadlineAlarms().records().values.sorted { $0.title < $1.title }
        alarmLog = DeadlineAlarms().logLines
        alarms = ((try? AlarmManager.shared.alarms) ?? []).map { alarm in
            let fires: Date? = if case .fixed(let date) = alarm.schedule { date } else { nil }
            return (id: String(alarm.id.uuidString.prefix(4)), state: String(describing: alarm.state), fires: fires)
        }
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
    @Environment(\.proEntitlements) private var pro
    @Environment(\.modelContext) private var context
    @Environment(\.moneyEscalation) private var escalation
    @State private var confirmingClear = false
    @State private var trialReminderNote: String?
    @State private var demoNote: String?
    @State private var demoBusy = false
    @State private var proOverride = ProEntitlements.debugOverride

    public init() {}

    public var body: some View {
        List {
            NavigationLink("Reminders, alarm + time travel (A2, A4)") { ReminderDebugView() }

            if let capture = CaptureDebugLog.last {
                Section("Last share-sheet capture (A7)") {
                    Text(capture).font(.caption.monospaced()).textSelection(.enabled)
                }
            }

            Section {
                Button("Load demo trials") {
                    demoBusy = true
                    Task {
                        let count = await DemoData.load(into: context, escalation: escalation)
                        demoNote = "Loaded \(count) demo trials (anything else was cleared). See the Money tab."
                        demoBusy = false
                    }
                }
                .disabled(demoBusy)
                Button("Clear all trials", role: .destructive) { confirmingClear = true }
                    .disabled(demoBusy)
                if demoBusy {
                    ProgressView()
                } else if let demoNote {
                    Text(demoNote).font(.footnote).foregroundStyle(.secondary)
                }
            } header: {
                Text("Demo data (P2)")
            } footer: {
                Text("Replaces all trials with: Spotify (3 days), Duolingo via Apple (tomorrow), Claude, Google AI Pro, and a cancelled Apple One.")
            }

            if let pro {
                Section {
                    LabeledContent("Pro", value: pro.isProNow ? "yes" : "no")
                    LabeledContent("Real purchase on this phone", value: pro.hasRealPro ? "yes" : "no")
                    Picker("Pro for testing", selection: $proOverride) {
                        Text("Real").tag(ProEntitlements.DebugOverride.real)
                        Text("Force Pro").tag(ProEntitlements.DebugOverride.pro)
                        Text("Pretend free").tag(ProEntitlements.DebugOverride.free)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: proOverride) { _, value in pro.setDebugOverride(value) }
                    .onAppear { proOverride = ProEntitlements.debugOverride }
                    Button("Show paywall") { pro.presentPaywall() }
                    Button("Preview \"trial ends tomorrow\" reminder in 1 minute") {
                        Task {
                            await ProEntitlements.scheduleTrialReminder(endsAt: .now.addingTimeInterval(24 * 60 * 60 + 60))
                            let fires = Date.now.addingTimeInterval(60).formatted(date: .omitted, time: .shortened)
                            trialReminderNote = "Scheduled for \(fires). Lock your phone and wait."
                        }
                    }
                    if let trialReminderNote {
                        Text(trialReminderNote).font(.footnote).foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Paywall (A8)")
                } footer: {
                    Text("Real: RevenueCat decides. Force Pro: Pro without buying. Pretend free: ignore this phone's purchase (for the free-plan check and the paywall shot); buying on the paywall switches back to Real. Test Store purchases are simulated and renew every few minutes, so Pro can lapse on its own.")
                }
            }
        }
        .navigationTitle("Debug")
        .confirmationDialog("Delete every trial?", isPresented: $confirmingClear, titleVisibility: .visible) {
            Button("Delete all", role: .destructive) {
                demoBusy = true
                Task {
                    let count = await DemoData.clear(context, escalation: escalation)
                    demoNote = "Deleted \(count) trials, with their reminders and alarms."
                    demoBusy = false
                }
            }
        }
    }
}
#endif
