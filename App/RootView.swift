import MoneyKit
import SharedKit
import SwiftUI

struct RootView: View {
    @Bindable private var decide = DecideRouter.shared

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
        .sheet(item: $decide.pending) { request in
            DecideView(itemID: request.itemID)
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
