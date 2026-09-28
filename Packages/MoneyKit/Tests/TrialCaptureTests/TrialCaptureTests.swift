import Foundation
import Testing
@testable import TrialCapture

@Suite struct PatternExtractorTests {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Chicago")!
        return calendar
    }()
    static func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }
    let now = Self.calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 12))!

    @Test func endOfADetectedRangeIsTheChargeDay() {
        let text = "After your trial ends on October 26, 2026, you'll be charged $11.99/month."
        #expect(PatternExtractor.chargeDate(in: text, now: now, calendar: Self.calendar) == Self.day(2026, 10, 26))
    }

    @Test func wordsLikeTodayAreNotDates() {
        let text = "Free trial ends Oct 10, 2026\nToday's total: US$0.00"
        #expect(PatternExtractor.chargeDate(in: text, now: now, calendar: Self.calendar) == Self.day(2026, 10, 10))
    }

    /// Dev A's iPhone, 2026-09-28: Settings → Subscriptions with everything cancelled came back as
    /// "Apple TV · $190.00 · charges Sep 27". Nothing on that screen is an upcoming charge.
    @Test func inactiveSubscriptionsScreenYieldsNoChargeOrPrice() {
        let text = """
            5:44 ~
            90
            Subscriptions
            Inactive
            Apple TV
            Apple TV Channel
            Canceled February 15
            Apple Music
            Individual
            Canceled January 10
            Options
            Apple One
            Get more when you bundle. Enjoy Apple TV,
            Try It Free
            """
        let result = PatternExtractor.extract(from: text, now: now, calendar: Self.calendar)
        #expect(result.chargeDate == nil)
        #expect(result.amountCents == nil)
    }

    @Test func clockTimesAreNotDates() {
        #expect(!PatternExtractor.looksLikeCalendarDate("5:44"))
        #expect(!PatternExtractor.looksLikeCalendarDate("Today"))
        #expect(PatternExtractor.looksLikeCalendarDate("Oct 26, 2026"))
        #expect(PatternExtractor.looksLikeCalendarDate("10/3/2026"))
        #expect(PatternExtractor.looksLikeCalendarDate("7 Dec 2026"))
    }

    @Test func trialLengthCountsFromToday() {
        #expect(PatternExtractor.chargeDate(in: "14-day free trial\nThen $12.99/month", now: now, calendar: Self.calendar) == Self.day(2026, 10, 11))
        #expect(PatternExtractor.chargeDate(in: "1-month free trial", now: now, calendar: Self.calendar) == Self.day(2026, 10, 27))
    }

    @Test func recurringPriceBeatsZeroAndOneTimeAmounts() {
        let text = "$0.00 due today\nStarting then, you'll be billed $18.99 per month"
        let result = PatternExtractor.extract(from: text, now: now, calendar: Self.calendar)
        #expect(result.amountCents == 1899)
    }

    @Test func currencyVariants() {
        #expect(PatternExtractor.amounts(in: "US$22.99/mo").first?.cents == 2299)
        #expect(PatternExtractor.amounts(in: "9,99 EUR per month").first?.currencyCode == "EUR")
        #expect(PatternExtractor.amounts(in: "£5.99 a month").first?.cents == 599)
    }

    @Test func firstNamedServiceWinsAndLongerNamesSwallowShorterOnes() {
        #expect(PatternExtractor.serviceName(in: "Apple One\nApple Music\nApple Arcade", knownServices: []) == "Apple One")
        #expect(PatternExtractor.serviceName(in: "YouTube Premium\nYour trial ends", knownServices: []) == "YouTube Premium")
    }

    @Test func ocrLookAlikesStillMatch() {
        #expect(PatternExtractor.serviceName(in: "Google Al Pro (2 TB)", knownServices: ["Google AI Pro"]) == "Google AI Pro")
    }

    @Test func appleBillingSignals() {
        #expect(PatternExtractor.looksBilledByApple("Confirm with Side Button"))
        #expect(PatternExtractor.looksBilledByApple("Cancel anytime in Settings > Apple Account"))
        #expect(!PatternExtractor.looksBilledByApple("Manage your Hulu account"))
    }
}

@Suite struct AIFactCheckTests {
    let calendar = PatternExtractorTests.calendar
    let now = PatternExtractorTests.calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 12))!
    let text = "Spotify\nAfter your trial ends on October 26, 2026, you'll be charged $11.99/month."

    func merged(_ answer: AIExtractor.Answer) -> TrialCandidate {
        let patterns = PatternExtractor.extract(from: text, now: now, calendar: calendar)
        return TrialExtractor.merge(ai: answer, patterns: patterns, text: text, now: now, calendar: calendar)
    }

    @Test func agreeingAnswerIsKept() {
        let result = merged(.init(serviceName: "Spotify", price: 11.99, chargeDate: "2026-10-26", billedByApple: false))
        #expect(result.amountCents == 1199)
        #expect(result.chargeDate == PatternExtractorTests.day(2026, 10, 26))
        #expect(result.source == .ai)
    }

    @Test func aPriceNotInTheTextIsIgnored() {
        #expect(merged(.init(serviceName: "Spotify", price: 9.99, chargeDate: "", billedByApple: false)).amountCents == 1199)
    }

    @Test func aDateNotInTheTextIsIgnored() {
        #expect(merged(.init(serviceName: "Spotify", price: 0, chargeDate: "2026-10-01", billedByApple: false)).chargeDate == PatternExtractorTests.day(2026, 10, 26))
    }

    @Test func aNameNotInTheTextIsIgnoredAndAppleNeedsEvidence() {
        let odd = "Premium Student\nYour next bill is for $6.99 on 10/10/2026."
        let patterns = PatternExtractor.extract(from: odd, now: now, calendar: calendar)
        let result = TrialExtractor.merge(ai: .init(serviceName: "Netflix", price: 6.99, chargeDate: "2026-10-10", billedByApple: true), patterns: patterns, text: odd, now: now, calendar: calendar)
        #expect(result.serviceName == nil)
        #expect(result.billedByApple == false)
    }
}
