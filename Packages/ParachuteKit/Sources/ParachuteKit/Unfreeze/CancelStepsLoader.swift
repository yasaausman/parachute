import Foundation
import SharedKit

public actor CancelStepsLoader: Sendable {
    private var cachedFile: CancelStepsFile?

    public init() {}

    public func loadFile() throws -> CancelStepsFile {
        if let cachedFile {
            return cachedFile
        }
        guard let url = CancelStepsFile.bundledURL else {
            throw URLError(.fileDoesNotExist)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let file = try decoder.decode(CancelStepsFile.self, from: data)
        self.cachedFile = file
        return file
    }

    public func plan(forServiceID serviceID: String) throws -> UnfreezePlan? {
        let file = try loadFile()
        guard let service = file.services.first(where: { $0.id == serviceID }) else {
            return nil
        }
        return UnfreezePlan(steps: service.steps, source: .curated, isSuggested: false)
    }

    public func plan(forServiceName serviceName: String) throws -> UnfreezePlan? {
        let file = try loadFile()
        let query = serviceName.lowercased()
        guard let service = file.services.first(where: { 
            let name = $0.name.lowercased()
            return name == query || name.contains(query) || query.contains(name)
        }) else {
            return nil
        }
        return UnfreezePlan(steps: service.steps, source: .curated, isSuggested: false)
    }
}
