import MoneyKit
import ParachuteKit
import SharedKit
import SwiftData
import SwiftUI

struct RootView: View {
    @State private var router = SheetRouter()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.moneyEscalation) private var escalation
    @Environment(\.proEntitlements) private var pro
    @Query private var deadlines: [MoneyDeadline]
    private let decide = DecideRouter.shared

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Money", systemImage: "dollarsign.circle") {
                NavigationStack { MoneyListView() }
            }
            Tab("Tasks", systemImage: "checklist") {
                TaskListView()
            }
            Tab("Refunded", systemImage: "trophy") {
                ScoreboardView()
            }
            #if DEBUG
            Tab("Debug", systemImage: "ladybug") {
                NavigationStack { MoneyDebugMenu() }
            }
            #endif
        }
        .tint(Theme.accent)
        .sheet(item: $router.sheet) { sheet in
            switch sheet {
            case .decide(let itemID):
                DecideRoute(itemID: itemID) { request in
                    router.unfreeze(request, itemID: itemID)
                }
            case .paywall:
                if let pro { PaywallView(entitlements: pro) }
            }
        }
        .fullScreenCover(item: $router.frozen) { frozen in
            UnfreezeHost(request: frozen.request, itemID: frozen.itemID)
        }
        // Trials saved from the share sheet get their alarm when the app comes to the front.
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await escalation?.resync(deadlines) }
        }
        // Alarm "Decide", reminder taps and trial rows all land here.
        .onChange(of: decide.pending, initial: true) { _, request in
            guard let request else { return }
            router.sheet = .decide(itemID: request.itemID)
            decide.pending = nil
        }
        // `presentPaywall()` (A's trial limit, B's gating) lands here.
        .onChange(of: pro?.isPaywallPresented) { _, presented in
            guard presented == true else { return }
            router.sheet = .paywall
            pro?.isPaywallPresented = false
        }
        // Pro arms the final-day alarms; losing it disarms them.
        .onChange(of: pro?.isProNow) { _, _ in
            Task { await escalation?.resync(deadlines) }
        }
    }
}

/// Reminders and alarms carry an item ID. Task IDs (B5) resume the task; money IDs open Decide.
private struct DecideRoute: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var tasks: [FrozenTask]
    let itemID: UUID
    let onFrozen: (UnfreezeRequest) -> Void

    init(itemID: UUID, onFrozen: @escaping (UnfreezeRequest) -> Void) {
        self.itemID = itemID
        self.onFrozen = onFrozen
        _tasks = Query(filter: #Predicate<FrozenTask> { $0.id == itemID })
    }

    var body: some View {
        if let task = tasks.first {
            TaskPlayerView(task: task) { dismiss() }
        } else {
            DecideView(itemID: itemID, onFrozen: onFrozen)
        }
    }
}
