import MoneyKit
import SharedKit
import SwiftUI

struct RootView: View {
    @State private var router = SheetRouter()
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
            }
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
