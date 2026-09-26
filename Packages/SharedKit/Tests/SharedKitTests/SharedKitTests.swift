import Foundation
import SwiftData
import Testing
@testable import SharedKit

@Suite struct CancelStepsFileTests {
    @Test func bundledFileDecodes() throws {
        let url = try #require(CancelStepsFile.bundledURL)
        let file = try JSONDecoder().decode(CancelStepsFile.self, from: Data(contentsOf: url))
        #expect(file.version == 1)
        #expect(!file.services.isEmpty)
    }
}

@Suite struct ModelTests {
    @Test func statusRoundTripsThroughRawValue() {
        let deadline = MoneyDeadline(serviceName: "Hulu", amountCents: 1799, dueDate: .now, billedByApple: false)
        #expect(deadline.status == .tracking)
        deadline.status = .cancelled
        #expect(deadline.statusRaw == "cancelled")
    }

    @Test func inMemoryContainerStoresEveryModel() throws {
        let container = try SharedStore.makeContainer(inMemory: true)
        let context = ModelContext(container)
        context.insert(MoneyDeadline(serviceName: "Hulu", amountCents: 1799, dueDate: .now, billedByApple: false))
        context.insert(FrozenTask(title: "Essay", steps: [MicroStep(order: 0, text: "Open a doc.", seconds: 10, source: .ai)]))
        context.insert(CompletionRecord(kind: .moneyCancelled, title: "Cancelled Hulu", amountCents: 1799))
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<MoneyDeadline>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<MicroStep>()) == 1)
    }

    @Test func centsFormatting() {
        #expect(1799.formattedCents() == "$17.99")
    }
}

@Suite struct FakeTests {
    @Test func fakeSchedulerRecordsCalls() async throws {
        let fake = FakeEscalationScheduler()
        let id = UUID()
        try await fake.schedule(itemID: id, title: "Hulu", due: .now, kind: .money(amountCents: 1799))
        await fake.resolve(itemID: id)
        #expect(await fake.calls.count == 2)
    }

    @Test func fakeUnfreezeProviderReturnsFiveShortSteps() async throws {
        let plan = try await FakeUnfreezeProvider().plan(for: .task(title: "Essay", dueDate: nil))
        #expect(plan.steps.count == 5)
        #expect(plan.steps.allSatisfy { $0.seconds <= 90 && $0.url == nil })
    }
}
