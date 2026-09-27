import MoneyKit
import ParachuteKit
import SharedKit
import SwiftData
import SwiftUI

struct RootView: View {
    @Bindable private var decide = DecideRouter.shared

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
        .sheet(item: $decide.pending) { request in
            DecideRoute(itemID: request.itemID)
        }
    }
}

/// Reminders and alarms carry an item ID. Task IDs (B5) resume the task; money IDs open Decide.
private struct DecideRoute: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var tasks: [FrozenTask]
    let itemID: UUID

    init(itemID: UUID) {
        self.itemID = itemID
        _tasks = Query(filter: #Predicate<FrozenTask> { $0.id == itemID })
    }

    var body: some View {
        if let task = tasks.first {
            TaskPlayerView(task: task) { dismiss() }
        } else {
            DecideView(itemID: itemID)
        }
    }
}

#Preview {
    RootView()
}
