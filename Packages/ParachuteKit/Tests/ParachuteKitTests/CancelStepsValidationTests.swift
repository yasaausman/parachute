import XCTest
import SharedKit
@testable import ParachuteKit

final class CancelStepsValidationTests: XCTestCase {
    /// SharedKit's types have no public memberwise init, so fixtures go through JSON like the real file.
    private func service(
        id: String = "hulu", name: String = "Hulu", verifiedOn: String = "2026-09-26", steps: [PlanStep]
    ) -> CancelStepsFile.Service {
        try! JSONDecoder().decode(CancelStepsFile.Service.self, from: serviceJSON(id: id, name: name, verifiedOn: verifiedOn, steps: steps))
    }

    private func serviceJSON(id: String, name: String, verifiedOn: String, steps: [PlanStep]) -> Data {
        let stepsJSON = String(decoding: try! JSONEncoder().encode(steps), as: UTF8.self)
        return Data(#"{"id":"\#(id)","name":"\#(name)","verifiedOn":"\#(verifiedOn)","verifiedBy":"A","steps":\#(stepsJSON)}"#.utf8)
    }

    private func file(_ services: [CancelStepsFile.Service]) -> CancelStepsFile {
        let body = services.map { String(decoding: try! JSONEncoder().encode($0), as: UTF8.self) }.joined(separator: ",")
        return try! JSONDecoder().decode(CancelStepsFile.self, from: Data(#"{"version":1,"services":[\#(body)]}"#.utf8))
    }

    func testBundledFileIsValid() throws {
        let url = try XCTUnwrap(CancelStepsFile.bundledURL, "Missing CancelSteps.json")
        let file = try JSONDecoder().decode(CancelStepsFile.self, from: Data(contentsOf: url))
        XCTAssertFalse(file.services.isEmpty)
        XCTAssertEqual(CancelStepsValidator.issues(in: file), [], "Fix CancelSteps.json")
    }

    func testRejectsMissingSteps() {
        XCTAssertFalse(CancelStepsValidator.isValid(service(steps: [])))
    }

    func testRejectsStepOver90Seconds() {
        XCTAssertFalse(CancelStepsValidator.isValid(service(steps: [PlanStep(text: "Tap Cancel.", seconds: 91)])))
    }

    func testRejectsZeroSeconds() {
        XCTAssertFalse(CancelStepsValidator.isValid(service(steps: [PlanStep(text: "Tap Cancel.", seconds: 0)])))
    }

    func testRejectsEmptyText() {
        XCTAssertFalse(CancelStepsValidator.isValid(service(steps: [PlanStep(text: "  ", seconds: 10)])))
    }

    func testRejectsUnverifiedService() {
        XCTAssertFalse(CancelStepsValidator.isValid(service(verifiedOn: "", steps: [PlanStep(text: "Tap Cancel.", seconds: 10)])))
    }

    func testRejectsNonHTTPSURL() {
        let step = PlanStep(text: "Open the account page.", seconds: 10, url: URL(string: "http://example.com"))
        XCTAssertFalse(CancelStepsValidator.isValid(service(steps: [step])))
    }

    func testRejectsDuplicateIDs() {
        let ok = service(steps: [PlanStep(text: "Tap Cancel.", seconds: 10)])
        let parsed = self.file([ok, ok])
        XCTAssertEqual(CancelStepsValidator.issues(in: parsed).map(\.problem), ["duplicate id"])
    }

    func testAcceptsGoodService() {
        XCTAssertTrue(CancelStepsValidator.isValid(service(steps: [PlanStep(text: "Tap Cancel.", seconds: 90)])))
    }

    func testLoaderDropsInvalidServices() async throws {
        let bad = service(id: "bad", steps: [])
        let good = service(id: "good", steps: [PlanStep(text: "Tap Cancel.", seconds: 10)])
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cancel-\(UUID()).json")
        try JSONEncoder().encode(self.file([bad, good])).write(to: url)
        let loader = CancelStepsLoader(url: url)
        let ids = try await loader.loadFile().services.map(\.id)
        XCTAssertEqual(ids, ["good"])
    }
}
