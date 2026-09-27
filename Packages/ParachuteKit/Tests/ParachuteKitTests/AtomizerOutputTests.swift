import XCTest
import SharedKit
@testable import ParachuteKit

/// Atomizer output schema (CLAUDE.md: tests for atomizer output) and "Break it smaller" edits.
final class AtomizerOutputTests: XCTestCase {
    func testStripsURLsAndBareDomains() {
        let steps = StepSanitizer.sanitizeAI([
            PlanStep(text: "Go to https://hulu.com/account and log in.", seconds: 30),
            PlanStep(text: "Open www.netflix.com/cancelplan now", seconds: 30),
            PlanStep(text: "Visit hulu.com/account.", seconds: 30),
        ])
        for step in steps {
            XCTAssertFalse(step.text.localizedCaseInsensitiveContains("http"), step.text)
            XCTAssertFalse(step.text.localizedCaseInsensitiveContains(".com"), step.text)
            XCTAssertNil(step.url)
        }
        XCTAssertEqual(steps.first?.text, "Go to and log in.")
    }

    func testClampsSecondsAndDropsEmptyAndDuplicateSteps() {
        let steps = StepSanitizer.sanitizeAI([
            PlanStep(text: "Open a blank doc.", seconds: 0),
            PlanStep(text: "open a blank doc.", seconds: 20),
            PlanStep(text: "   ", seconds: 20),
            PlanStep(text: "https://example.com", seconds: 20),
            PlanStep(text: "Write the intro.", seconds: 600),
        ])
        XCTAssertEqual(steps.map(\.text), ["Open a blank doc.", "Write the intro."])
        XCTAssertEqual(steps.map(\.seconds), [5, 90])
    }

    func testKeepsNormalText() {
        let text = "Open Settings. Tap your name, then 'Subscriptions'."
        XCTAssertEqual(StepSanitizer.sanitizeAI([PlanStep(text: text, seconds: 20)]).first?.text, text)
    }

    func testBreakItSmallerReplacesOnlyTheCurrentStep() {
        let plan = ["a", "b", "c"].map { PlanStep(text: $0, seconds: 10) }
        let smaller = ["b1", "b2"].map { PlanStep(text: $0, seconds: 5) }
        XCTAssertEqual(PlanEditing.replace(stepAt: 1, in: plan, with: smaller).map(\.text), ["a", "b1", "b2", "c"])
        XCTAssertEqual(PlanEditing.replace(stepAt: 1, in: plan, with: []).map(\.text), ["a", "b", "c"])
        XCTAssertEqual(PlanEditing.replace(stepAt: 9, in: plan, with: smaller).map(\.text), ["a", "b", "c"])
    }
}
