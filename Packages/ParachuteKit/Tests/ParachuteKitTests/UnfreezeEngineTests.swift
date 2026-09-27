import XCTest
import SharedKit
@testable import ParachuteKit

final class UnfreezeEngineTests: XCTestCase {
    
    private func getFirstRealService() throws -> CancelStepsFile.Service? {
        guard let url = CancelStepsFile.bundledURL else { return nil }
        let data = try Data(contentsOf: url)
        let file = try JSONDecoder().decode(CancelStepsFile.self, from: data)
        return file.services.first
    }

    func testKnownServiceIDReturnsCuratedPlan() async throws {
        let engine = UnfreezeEngine()
        guard let service = try getFirstRealService() else {
            XCTFail("No services in CancelSteps.json to test with")
            return
        }
        
        let request = UnfreezeRequest.cancel(serviceID: service.id, serviceName: service.name, billedByApple: false)
        let plan = try await engine.plan(for: request)
        
        XCTAssertEqual(plan.source, .curated)
        XCTAssertFalse(plan.isSuggested)
        XCTAssertEqual(plan.steps.count, service.steps.count)
    }

    func testKnownServiceNameReturnsCuratedPlan() async throws {
        let engine = UnfreezeEngine()
        guard let service = try getFirstRealService() else { return }
        
        // Use part of the name to test fuzzy match
        let request = UnfreezeRequest.cancel(serviceID: nil, serviceName: service.name.lowercased(), billedByApple: false)
        let plan = try await engine.plan(for: request)
        
        XCTAssertEqual(plan.source, .curated)
        XCTAssertFalse(plan.isSuggested)
    }

    func testUnknownServiceBilledByAppleReturnsAppleSubscriptions() async throws {
        let engine = UnfreezeEngine()
        let request = UnfreezeRequest.cancel(serviceID: "unknown_id_xyz", serviceName: "Some Random App", billedByApple: true)
        let plan = try await engine.plan(for: request)
        
        XCTAssertEqual(plan.source, .appleSubscriptions)
        XCTAssertFalse(plan.isSuggested)
        XCTAssertEqual(plan.steps.count, 5) // As per requirements
    }

    func testUnknownServiceNotBilledByAppleReturnsAIFallback() async throws {
        let engine = UnfreezeEngine()
        let request = UnfreezeRequest.cancel(serviceID: "unknown_id_xyz", serviceName: "Some Random App", billedByApple: false)
        let plan = try await engine.plan(for: request)
        
        XCTAssertEqual(plan.source, .ai)
        XCTAssertTrue(plan.isSuggested)
    }

    func testTaskRequestReturnsAIPlan() async throws {
        let engine = UnfreezeEngine()
        let request = UnfreezeRequest.task(title: "Do laundry", dueDate: nil)
        let plan = try await engine.plan(for: request)
        
        XCTAssertEqual(plan.source, .ai)
        XCTAssertTrue(plan.isSuggested)
    }
}
