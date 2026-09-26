import Foundation
import SwiftData

/// The App Group shared by the app, widgets, and share extension.
/// Each target's Info.plist carries `ParachuteAppGroup` (set from `PARACHUTE_APP_GROUP` in Config/Base.xcconfig),
/// so every developer can use their own bundle ID prefix.
public enum AppGroup {
    public static let infoPlistKey = "ParachuteAppGroup"

    public static var identifier: String? {
        Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String
    }

    public static var defaults: UserDefaults {
        identifier.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }
}

public enum SharedStore {
    public static let schema = Schema([
        MoneyDeadline.self,
        FrozenTask.self,
        MicroStep.self,
        CompletionRecord.self,
    ])

    /// The on-disk store in the App Group container. Falls back to the app's own container
    /// when no App Group is configured (e.g. unit tests).
    public static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else if let group = AppGroup.identifier {
            configuration = ModelConfiguration(schema: schema, groupContainer: .identifier(group))
        } else {
            configuration = ModelConfiguration(schema: schema)
        }
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
