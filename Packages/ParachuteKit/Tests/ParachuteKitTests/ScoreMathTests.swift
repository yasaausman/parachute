import XCTest
import SharedKit
@testable import ParachuteKit

/// B6 "Done when": the numbers are right after cancel, keep (no $), task done, and snooze (nothing).
final class ScoreMathTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }()

    private func day(_ d: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: d, hour: hour))!
    }

    func testCancelAddsDollarsKeepDoesNot() {
        let entries = [
            ScoreEntry(kind: .moneyCancelled, amountCents: 1799, date: day(1)),
            ScoreEntry(kind: .moneyKept, amountCents: 999, date: day(1)),
            ScoreEntry(kind: .moneyCancelled, amountCents: nil, date: day(1)),
        ]
        XCTAssertEqual(ScoreMath.refundedCents(entries), 1799)
        XCTAssertEqual(ScoreMath.tasksUnfrozen(entries), 0)
    }

    func testTaskDoneCountsAsTask() {
        let entries = [ScoreEntry(kind: .taskDone, amountCents: nil, date: day(1))]
        XCTAssertEqual(ScoreMath.tasksUnfrozen(entries), 1)
        XCTAssertEqual(ScoreMath.refundedCents(entries), 0)
    }

    func testSnoozeWritesNothingSoEmptyIsZero() {
        XCTAssertEqual(ScoreMath.refundedCents([]), 0)
        XCTAssertEqual(ScoreMath.tasksUnfrozen([]), 0)
        XCTAssertEqual(ScoreMath.bestRun([], calendar: calendar), 0)
    }

    func testBestRunKeepsTheLongestRunAfterAGap() {
        let entries = [1, 2, 3, 3, 7, 8].map { ScoreEntry(kind: .taskDone, amountCents: nil, date: day($0)) }
        XCTAssertEqual(ScoreMath.bestRun(entries, calendar: calendar), 3)
    }

    func testBestRunCountsCalendarDaysNotHours() {
        let entries = [day(1, hour: 23), day(2, hour: 1)].map { ScoreEntry(kind: .taskDone, amountCents: nil, date: $0) }
        XCTAssertEqual(ScoreMath.bestRun(entries, calendar: calendar), 2)
    }

    func testMonthsNewestFirst() {
        let oct = calendar.date(from: DateComponents(year: 2026, month: 10, day: 2))!
        let months = ScoreMath.months([day(1), day(20), oct], calendar: calendar)
        XCTAssertEqual(months.count, 2)
        XCTAssertEqual(calendar.component(.month, from: months[0]), 10)
    }
}
