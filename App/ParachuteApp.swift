import AppIntents
import MoneyKit
import ParachuteKit
import SharedKit
import SwiftData
import SwiftUI
import UserNotifications

@main
struct ParachuteApp: App {
    @State private var dependencies: AppDependencies
    private let container: ModelContainer

    init() {
        let container: ModelContainer
        do {
            container = try SharedStore.makeContainer()
        } catch {
            fatalError("Couldn't open the shared store: \(error)")
        }
        self.container = container
        _dependencies = State(initialValue: .live(container: container))
        RevenueCatBootstrap.configureIfPossible()
        UNUserNotificationCenter.current().delegate = ForegroundNotificationPresenter.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                .environment(\.moneyEscalation, dependencies.moneyEscalation)
                .environment(\.parachute, dependencies.parachute)
        }
        .modelContainer(container)
    }
}

/// Pulls App Intents (the alarm's Stop/Decide intents) out of the local packages.
struct ParachuteAppIntentsPackage: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] {
        [MoneyKitIntentsPackage.self]
    }
}
