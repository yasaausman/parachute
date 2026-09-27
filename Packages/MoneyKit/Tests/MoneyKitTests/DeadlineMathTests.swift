import Foundation
import SharedKit
import Testing
@testable import MoneyKit

@Suite struct DeadlineMathTests {
    /// Pinned so results don't depend on the machine running the tests.
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    @Test(arguments: [
        (date(2026, 9, 26, 23, 59), date(2026, 9, 26, 0, 0), 0),
        (date(2026, 9, 26, 23, 59), date(2026, 9, 27, 0, 1), 1),
        (date(2026, 9, 26, 0, 1), date(2026, 9, 29, 23, 0), 3),
        (date(2026, 9, 26), date(2026, 9, 25), -1),
        (date(2026, 9, 26), date(2026, 9, 20), -6),
        (date(2026, 12, 31), date(2027, 1, 1), 1),
    ])
    func calendarDaysCountsMidnights(now: Date, due: Date, expected: Int) {
        #expect(DeadlineMath.calendarDays(from: now, to: due, calendar: Self.calendar) == expected)
    }

    @Test func calendarDaysSurvivesDaylightSavingEnd() {
        // US DST ends Sun Nov 1, 2026: that day is 25 hours long.
        let now = Self.date(2026, 10, 31, 23, 30)
        #expect(DeadlineMath.calendarDays(from: now, to: Self.date(2026, 11, 2, 0, 30), calendar: Self.calendar) == 2)
    }

    @Test func calendarDaysSurvivesDaylightSavingStart() {
        // US DST starts Sun Mar 14, 2027: that day is 23 hours long.
        let now = Self.date(2027, 3, 13, 0, 30)
        #expect(DeadlineMath.calendarDays(from: now, to: Self.date(2027, 3, 15, 0, 0), calendar: Self.calendar) == 2)
    }

    @Test(arguments: [(0, "today"), (1, "tomorrow"), (3, "in 3 days"), (-1, "was due yesterday"), (-4, "was due 4 days ago")])
    func countdownText(days: Int, expected: String) {
        #expect(DeadlineMath.countdownText(days: days) == expected)
    }

    @Test func summaryReadsLikeTheWidget() {
        let text = DeadlineMath.summary(
            serviceName: "Hulu", amountCents: 1799, currencyCode: "USD",
            due: Self.date(2026, 9, 29), now: Self.date(2026, 9, 26), calendar: Self.calendar
        )
        #expect(text == "Hulu · $17.99 in 3 days")
    }

    @Test func appleBilledDeadlineIsADayEarly() {
        let due = Self.date(2026, 10, 26, 0, 0)
        #expect(DeadlineMath.cancelBy(due: due, billedByApple: true) == due.addingTimeInterval(-86_400))
        #expect(DeadlineMath.cancelBy(due: due, billedByApple: false) == due)
    }

    @Test(arguments: [("17.99", 1799), ("6.99", 699), ("20", 2000), ("0.005", 1), ("21.954", 2195)])
    func centsFromDecimal(input: String, expected: Int) {
        #expect(DeadlineMath.cents(from: Decimal(string: input)!) == expected)
    }

    @Test func normalizedDueDateIsStartOfDay() {
        let normalized = DeadlineMath.normalizedDueDate(Self.date(2026, 10, 10, 17, 45), calendar: Self.calendar)
        #expect(normalized == Self.date(2026, 10, 10, 0, 0))
    }
}

@Suite struct CuratedServicesTests {
    let services = CuratedServices.load()

    @Test func bundledServicesLoad() {
        #expect(services.map(\.id).contains("spotify"))
    }

    @Test(arguments: [
        ("Spotify", "spotify"), ("  spotify ", "spotify"),
        ("Google One", "google-one"), ("google ai pro", "google-one"), ("Google AI Pro (Google One)", "google-one"),
        ("Apple One", "apple-one"), ("Claude", "claude"),
    ])
    func matchesTypedNames(typed: String, expected: String) {
        #expect(CuratedServices.serviceID(for: typed, in: services) == expected)
    }

    @Test(arguments: ["Netflix", "", "Apple", "Google"])
    func unknownNamesDontMatch(typed: String) {
        #expect(CuratedServices.serviceID(for: typed, in: services) == nil)
    }
}

@Suite struct CuratedShortNameTests {
    @Test func shortNameDropsParenthetical() throws {
        let google = try #require(CuratedServices.load().first { $0.id == "google-one" })
        #expect(CuratedServices.shortName(google) == "Google AI Pro")
        #expect(CuratedServices.serviceID(for: CuratedServices.shortName(google), in: CuratedServices.load()) == "google-one")
    }
}
