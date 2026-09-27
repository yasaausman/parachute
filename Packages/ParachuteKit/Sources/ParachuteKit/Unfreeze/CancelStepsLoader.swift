import Foundation
import SharedKit

/// Loads the bundled `CancelSteps.json` once. Services that fail `CancelStepsValidator` are left out,
/// so a bad entry falls through to the Apple path or AI instead of showing a broken plan.
public actor CancelStepsLoader {
    private var cachedFile: CancelStepsFile?
    private let url: URL?

    public init(url: URL? = CancelStepsFile.bundledURL) {
        self.url = url
    }

    public func loadFile() throws -> CancelStepsFile {
        if let cachedFile { return cachedFile }
        guard let url else { throw URLError(.fileDoesNotExist) }
        var file = try JSONDecoder().decode(CancelStepsFile.self, from: Data(contentsOf: url))
        file.services = file.services.filter(CancelStepsValidator.isValid)
        cachedFile = file
        return file
    }

    public func service(id: String) -> CancelStepsFile.Service? {
        (try? loadFile())?.services.first { $0.id == id }
    }

    /// Matches "claude pro" to "Claude" and "Google One" to "Google AI Pro (Google One)".
    public func service(named name: String) -> CancelStepsFile.Service? {
        let query = Self.normalize(name)
        guard !query.isEmpty, let services = (try? loadFile())?.services else { return nil }
        return services.first { Self.normalize($0.name) == query }
            ?? services.first {
                let candidate = Self.normalize($0.name)
                return candidate.contains(query) || query.contains(candidate)
            }
    }

    static func normalize(_ name: String) -> String {
        name.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

extension CancelStepsFile.Service {
    var plan: UnfreezePlan { UnfreezePlan(steps: steps, source: .curated, isSuggested: false) }

    /// Curated entries for Apple's own services (e.g. `apple-one`) are already Apple-settings steps.
    var isAppleBilled: Bool { id.hasPrefix("apple-") }
}
