import MoneyKit
import SharedKit
import SwiftUI

struct RootView: View {
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
