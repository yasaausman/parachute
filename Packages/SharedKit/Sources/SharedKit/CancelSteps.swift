import Foundation

/// The shape of `Resources/CancelSteps.json` (content by Dev A, loaded + validated by Dev B).
public struct CancelStepsFile: Codable, Sendable, Hashable {
    public var version: Int
    public var services: [Service]

    public struct Service: Codable, Sendable, Hashable, Identifiable {
        public var id: String
        public var name: String
        public var verifiedOn: String
        public var verifiedBy: String
        public var steps: [PlanStep]
    }

    /// The bundled file.
    public static var bundledURL: URL? {
        Bundle.module.url(forResource: "CancelSteps", withExtension: "json")
    }
}
