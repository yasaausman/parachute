import AppIntents
import MoneyKit
import SharedKit
import SwiftData
import SwiftUI
import UserNotifications

@main
struct ParachuteApp: App {
    @State private var dependencies = AppDependencies.live
    private let container: ModelContainer

    init() {
        do {
            container = try SharedStore.makeContainer()
        } catch {
            fatalError("Couldn't open the shared store: \(error)")
        }
        RevenueCatBootstrap.configureIfPossible()
        UNUserNotificationCenter.current().delegate = ForegroundNotificationPresenter.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                .environment(\.moneyEscalation, dependencies.moneyEscalation)
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
