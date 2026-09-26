import Foundation
import SharedKit

/// The services with hand-verified cancel steps, for quick-pick and `serviceID` matching.
public enum CuratedServices {
    public static func load() -> [CancelStepsFile.Service] {
        guard let url = CancelStepsFile.bundledURL,
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(CancelStepsFile.self, from: data)
        else { return [] }
        return file.services
    }

    /// Matches a typed name to a curated service: "google one", "Google AI Pro" and "google-one"
    /// all find `google-one` ("Google AI Pro (Google One)").
    public static func serviceID(for typedName: String, in services: [CancelStepsFile.Service]) -> String? {
        let typed = normalize(typedName)
        guard !typed.isEmpty else { return nil }
        return services.first { service in
            aliases(for: service).contains(typed)
        }?.id
    }

    /// "Google AI Pro (Google One)" → "Google AI Pro", for chips and new items.
    public static func shortName(_ service: CancelStepsFile.Service) -> String {
        let base = service.name.split(separator: "(").first.map(String.init) ?? service.name
        return base.trimmingCharacters(in: .whitespaces)
    }

    static func aliases(for service: CancelStepsFile.Service) -> Set<String> {
        let parts = service.name
            .split(whereSeparator: { $0 == "(" || $0 == ")" })
            .map(String.init)
        return Set(([service.id, service.name] + parts).map(normalize).filter { !$0.isEmpty })
    }

    static func normalize(_ text: String) -> String {
        text.lowercased().filter { $0.isLetter || $0.isNumber }
    }
}
