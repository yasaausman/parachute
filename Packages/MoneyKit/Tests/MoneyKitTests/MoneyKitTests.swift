import Foundation
import Testing
@testable import MoneyKit

@Suite struct SpikeRearmTests {
    @Test func rearmDateIsInTheFuture() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        #expect(SpikeAlarm.nextFireDate(after: now) == now.addingTimeInterval(60))
    }
}
