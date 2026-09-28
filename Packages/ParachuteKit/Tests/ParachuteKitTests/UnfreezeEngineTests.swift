import XCTest
import SharedKit
@testable import ParachuteKit

/// Records calls and returns fixed steps, so the tests don't depend on Apple Intelligence.
private struct StubAtomizer: StepAtomizing {
    var isModelAvailable = true
    func atomize(taskTitle: String, dueDate: Date?) async -> [PlanStep] { [PlanStep(text: "Type your name.", seconds: 10)] }
    func atomizeCancel(serviceName: String) async -> [PlanStep] { [PlanStep(text: "Open the app.", seconds: 10)] }
    func breakSmaller(_ step: PlanStep, goal: String) async -> [PlanStep] {
        [PlanStep(text: "a", seconds: 5), PlanStep(text: "b", seconds: 5)]
    }
}

final class UnfreezeEngineTests: XCTestCase {
    private let engine = UnfreezeEngine(atomizer: StubAtomizer())

    // 1. Curated
    func testKnownServiceIDReturnsCuratedPlan() async throws {
        let plan = try await engine.plan(for: .cancel(serviceID: "spotify", serviceName: "Spotify", billedByApple: false))
        XCTAssertEqual(plan.source, .curated)
        XCTAssertFalse(plan.isSuggested)
        XCTAssertEqual(plan.steps.count, 4)
    }

    func testServiceNameMatchesCuratedWithoutID() async throws {
        let plan = try await engine.plan(for: .cancel(serviceID: nil, serviceName: "claude pro", billedByApple: false))
        XCTAssertEqual(plan.source, .curated)
        let google = try await engine.plan(for: .cancel(serviceID: nil, serviceName: "Google One", billedByApple: false))
        XCTAssertEqual(google.source, .curated)
    }

    func testEmptyNameDoesNotMatchCurated() async throws {
        let plan = try await engine.plan(for: .cancel(serviceID: nil, serviceName: "", billedByApple: false))
        XCTAssertEqual(plan.source, .ai)
    }

    func testAppleServiceStaysCuratedWhenBilledByApple() async throws {
        let plan = try await engine.plan(for: .cancel(serviceID: "apple-one", serviceName: "Apple One", billedByApple: true))
        XCTAssertEqual(plan.source, .curated)
    }

    // 2. Apple path (CLAUDE.md rule 8: web steps don't work for App Store billing)
    func testWebCuratedServiceBilledByAppleUsesApplePath() async throws {
        let plan = try await engine.plan(for: .cancel(serviceID: "spotify", serviceName: "Spotify", billedByApple: true))
        XCTAssertEqual(plan.source, .appleSubscriptions)
        XCTAssertFalse(plan.isSuggested)
    }

    func testUnknownServiceBilledByAppleUsesApplePath() async throws {
        let plan = try await engine.plan(for: .cancel(serviceID: nil, serviceName: "Some Random App", billedByApple: true))
        XCTAssertEqual(plan.source, .appleSubscriptions)
        XCTAssertTrue(plan.steps.contains { $0.text.contains("Some Random App") })
    }

    // 3. AI fallback
    func testUnknownWebServiceUsesSuggestedAISteps() async throws {
        let plan = try await engine.plan(for: .cancel(serviceID: "nope", serviceName: "Some Random App", billedByApple: false))
        XCTAssertEqual(plan.source, .ai)
        XCTAssertTrue(plan.isSuggested)
        XCTAssertEqual(plan.steps.map(\.text), ["Open the app."])
    }

    func testTaskUsesAtomizer() async throws {
        let plan = try await engine.plan(for: .task(title: "Essay", dueDate: nil))
        XCTAssertEqual(plan.source, .ai)
        XCTAssertTrue(plan.isSuggested)
        XCTAssertEqual(plan.steps.map(\.text), ["Type your name."])
    }

    // 4. Non-AI fallback: the real atomizer on a device without Apple Intelligence
    func testFallbacksAreValidAndLinkFree() {
        for steps in [Fallbacks.task("Essay"), Fallbacks.cancel("Hulu"), Fallbacks.smaller(PlanStep(text: "Write it", seconds: 90))] {
            XCTAssertFalse(steps.isEmpty)
            for step in steps {
                XCTAssertFalse(step.text.isEmpty)
                XCTAssertTrue((1...90).contains(step.seconds))
                XCTAssertNil(step.url)
            }
        }
    }

    func testBreakSmallerUsesAtomizer() async {
        let smaller = await engine.smallerSteps(for: PlanStep(text: "Write it", seconds: 90), goal: "Essay")
        XCTAssertEqual(smaller.map(\.text), ["a", "b"])
    }
}
