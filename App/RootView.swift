import MoneyKit
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
            Tab("Home", systemImage: "parachute") {
                placeholder("Home", detail: "I'm frozen → task path (B4)")
            }
            Tab("Money", systemImage: "dollarsign.circle") {
                NavigationStack { MoneyListView() }
            }
            Tab("Tasks", systemImage: "checklist") {
                placeholder("Tasks", detail: "Frozen tasks (B4)")
            }
            Tab("Refunded", systemImage: "trophy") {
                placeholder("ADHD Tax Refunded", detail: "Scoreboard (B6)")
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
                DecideView(itemID: itemID) { request in
                    router.sheet = .unfreeze(request, itemID: itemID)
                }
            case .unfreeze(let request, let itemID):
                UnfreezeHost(request: request, itemID: itemID)
            case .paywall:
                if let pro { PaywallView(entitlements: pro) }
            }
        }
        // `presentPaywall()` (A's list limit, B's gating) lands here.
        .onChange(of: pro?.isPaywallPresented) { _, presented in
            guard presented == true else { return }
            router.sheet = .paywall
            pro?.isPaywallPresented = false
        }
        // Pro arms the final-day alarms; losing it disarms them.
        .onChange(of: pro?.isProNow) { _, _ in
            Task { await escalation?.resync(deadlines) }
        }
        // Trials saved from the share sheet get their alarm when the app comes to the front.
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await escalation?.resync(deadlines) }
        }
        // Alarm "Decide", reminder taps and trial rows all land here.
        .onChange(of: decide.pending) { _, request in
            guard let request else { return }
            router.sheet = .decide(itemID: request.itemID)
            decide.pending = nil
        }
    }

    private func placeholder(_ title: String, detail: String) -> some View {
        NavigationStack {
            ContentUnavailableView(title, systemImage: "hammer", description: Text(detail))
                .navigationTitle(title)
        }
    }
}

#Preview {
    RootView()
}
