import AppIntents
import Foundation

/// Runs when the final-day alarm's Stop is used: brings it back in 30 minutes (CLAUDE.md rule 2).
public struct DeadlineAlarmStopIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Stop Deadline Alarm"
    public static let isDiscoverable = false

    @Parameter(title: "Item ID") public var itemID: String

    public init() {}

    public init(itemID: String) {
        self.itemID = itemID
    }

    public func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: itemID) {
            try await DeadlineAlarms().stopTapped(itemID: id)
        }
        return .result()
    }
}

/// Runs when "Decide" is tapped: opens the app on the Decide screen.
public struct DeadlineAlarmDecideIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Decide"
    public static let isDiscoverable = false
    public static let supportedModes: IntentModes = .foreground

    @Parameter(title: "Item ID") public var itemID: String

    public init() {}

    public init(itemID: String) {
        self.itemID = itemID
    }

    public func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: itemID) {
            try await DeadlineAlarms().decideTapped(itemID: id)
        }
        return .result()
    }
}

/// Lets the app target pick up MoneyKit's intents (App Intents metadata for packages).
public struct MoneyKitIntentsPackage: AppIntentsPackage {}
