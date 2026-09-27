import XCTest
import SharedKit
@testable import ParachuteKit

final class CancelStepsValidationTests: XCTestCase {
    func testCancelStepsFileIsValid() throws {
        // 1. File loads successfully
        guard let url = CancelStepsFile.bundledURL else {
            XCTFail("Missing CancelSteps.json")
            return
        }
        let data = try Data(contentsOf: url)
        let file = try JSONDecoder().decode(CancelStepsFile.self, from: data)
        
        var seenIDs = Set<String>()
        
        for service in file.services {
            // 2. non-empty id and name
            XCTAssertFalse(service.id.isEmpty, "Service id should not be empty")
            XCTAssertFalse(service.name.isEmpty, "Service name should not be empty for \(service.id)")
            
            // 3. verifiedOn non-empty
            XCTAssertFalse(service.verifiedOn.isEmpty, "verifiedOn should not be empty for \(service.id)")
            
            // 4. >= 1 step
            XCTAssertFalse(service.steps.isEmpty, "Service \(service.id) must have at least 1 step")
            
            for step in service.steps {
                // 5. non-empty text
                XCTAssertFalse(step.text.isEmpty, "Step text should not be empty in \(service.id)")
                // 6. seconds <= 90 and > 0
                XCTAssertTrue(step.seconds > 0 && step.seconds <= 90, "Step seconds must be > 0 and <= 90 in \(service.id)")
            }
            
            // 7. No duplicate service IDs
            XCTAssertFalse(seenIDs.contains(service.id), "Duplicate service ID found: \(service.id)")
            seenIDs.insert(service.id)
        }
    }
}
