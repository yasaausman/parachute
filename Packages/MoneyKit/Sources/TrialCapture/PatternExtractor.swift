import Foundation

/// The non-AI extractor (CLAUDE.md rule 3). Also the fact-checker for the AI: anything the
/// model returns must be backed by what this finds in the text.
public enum PatternExtractor {
    /// Common subscriptions, so a name can be found without AI. Curated services are added by the caller.
    public static let commonServices = [
        "Apple One", "Apple Music", "Apple TV", "Apple Arcade", "iCloud+",
        "Netflix", "Hulu", "Disney+", "Max", "Paramount+", "Peacock", "YouTube Premium", "YouTube TV",
        "Spotify", "Audible", "Amazon Prime", "Kindle Unlimited",
        "Duolingo", "Headspace", "Calm", "Strava", "Peloton",
        "ChatGPT", "Claude", "Google One", "Google AI Pro", "Gemini",
        "Adobe", "Canva", "Grammarly", "Notion", "Chegg", "Quizlet", "Microsoft 365", "Dropbox",
        "The New York Times", "LinkedIn Premium", "Tinder", "Bumble",
    ]

    public struct Amount: Hashable, Sendable {
        public var cents: Int
        public var currencyCode: String
        /// Next to "then", "/mo", "per month", "charged", "renews"…
        public var isRecurring: Bool
    }

    public static func extract(from text: String, now: Date, knownServices: [String] = [], calendar: Calendar = .current) -> TrialCandidate {
        let amount = amounts(in: text).first { $0.isRecurring } ?? amounts(in: text).first
        return TrialCandidate(
            serviceName: serviceName(in: text, knownServices: knownServices),
            amountCents: amount?.cents,
            currencyCode: amount?.currencyCode ?? "USD",
            chargeDate: chargeDate(in: text, now: now, calendar: calendar),
            billedByApple: looksBilledByApple(text),
            source: .patterns
        )
    }

    // MARK: Service

    /// The service named first in the text (usually the title), ignoring names inside a longer
    /// match ("Apple One" beats "Apple Music" further down; "YouTube Premium" beats "YouTube").
    public static func serviceName(in text: String, knownServices: [String]) -> String? {
        let haystack = normalize(text)
        let matches: [(name: String, key: String, position: Int)] = (knownServices + commonServices).compactMap { name in
            let key = normalize(name)
            guard !key.isEmpty, let range = haystack.range(of: key) else { return nil }
            return (name, key, haystack.distance(from: haystack.startIndex, to: range.lowerBound))
        }
        let outermost = matches.filter { match in
            !matches.contains { other in other.key != match.key && other.key.contains(match.key) }
        }
        return outermost.min { $0.position != $1.position ? $0.position < $1.position : $0.key.count > $1.key.count }?.name
    }

    /// Lowercased letters/digits/"+", with the OCR look-alikes l/I folded together ("Google Al Pro").
    static func normalize(_ text: String) -> String {
        String(text.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "+" }.map { $0 == "l" ? "i" : $0 })
    }

    // MARK: Money

    /// "$21.95", "US$22.99", "21.95 USD", "€9,99". Zero amounts ("$0.00 due today") are skipped.
    public static func amounts(in text: String) -> [Amount] {
        let pattern = #/(?<pre>US\$|\$|€|£)\s?(?<num>\d{1,4}(?:[.,]\d{2})?)|(?<num2>\d{1,4}[.,]\d{2})\s?(?<post>USD|EUR|GBP)/#
        let lowered = text.lowercased()
        var found: [Amount] = []
        for match in text.matches(of: pattern) {
            let raw = String(match.output.num ?? match.output.num2 ?? "")
            guard let value = Decimal(string: raw.replacingOccurrences(of: ",", with: ".")), value > 0 else { continue }
            let symbol = String(match.output.pre ?? match.output.post ?? "$")
            let code = switch symbol {
            case "€", "EUR": "EUR"
            case "£", "GBP": "GBP"
            default: "USD"
            }
            var cents = value * 100
            var rounded = Decimal()
            NSDecimalRound(&rounded, &cents, 0, .plain)

            let start = text.distance(from: text.startIndex, to: match.range.lowerBound)
            let end = text.distance(from: text.startIndex, to: match.range.upperBound)
            let window = lowered.slice(from: max(0, start - 24), to: min(lowered.count, end + 24))
            let recurring = ["/mo", "per month", "a month", "/month", "month", "/yr", "per year", "/year", "then", "renew", "charged", "charge", "billed", "payment", "bill"]
                .contains { window.contains($0) }
            found.append(Amount(cents: NSDecimalNumber(decimal: rounded).intValue, currencyCode: code, isRecurring: recurring))
        }
        return found
    }

    // MARK: Date

    /// The first charge: an explicit date near "ends / starting / renews / next payment / until",
    /// else "N-day free trial" counted from today. Past dates are ignored.
    public static func chargeDate(in text: String, now: Date, calendar: Calendar = .current) -> Date? {
        scoredDates(in: text, now: now, calendar: calendar).first?.date ?? trialLengthDate(in: text, now: now, calendar: calendar)
    }

    /// Every day the text could mean: printed future dates plus a trial-length date.
    public static func candidateDays(in text: String, now: Date, calendar: Calendar = .current) -> Set<Date> {
        var days = Set(scoredDates(in: text, now: now, calendar: calendar).map(\.date))
        if let length = trialLengthDate(in: text, now: now, calendar: calendar) { days.insert(length) }
        return days
    }

    /// Future dates in the text, best first (most charge-like words just before them).
    static func scoredDates(in text: String, now: Date, calendar: Calendar) -> [(date: Date, score: Int)] {
        let today = calendar.startOfDay(for: now)
        let lowered = text.lowercased()
        var found: [(date: Date, score: Int)] = []

        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) {
            let range = NSRange(text.startIndex..., in: text)
            for match in detector.matches(in: text, range: range) {
                guard let date = match.date, let swiftRange = Range(match.range, in: text) else { continue }
                let matched = String(text[swiftRange])
                // A charge date names a day: "Oct 26", "10/3/2026", "7 Dec". Not "Today" or a clock time ("5:44").
                guard looksLikeCalendarDate(matched) else { continue }
                // "ends on October 26" comes back as a range from now to Oct 26: the end is the date.
                let day = calendar.startOfDay(for: match.duration > 0 ? date.addingTimeInterval(match.duration) : date)
                guard day >= today else { continue }
                let start = text.distance(from: text.startIndex, to: swiftRange.lowerBound)
                let end = text.distance(from: text.startIndex, to: swiftRange.upperBound)
                // "Canceled February 15", "ended on…": a past event, not an upcoming charge.
                let justBefore = lowered.slice(from: max(0, start - 16), to: start)
                if ["cancel", "ended", "expired", "stopped", "since"].contains(where: justBefore.contains) { continue }
                let context = lowered.slice(from: max(0, start - 40), to: end)
                let keywords = ["end", "starting", "renew", "next payment", "next bill", "billing date", "charge", "until", "on "]
                let score = keywords.filter { context.contains($0) }.count
                found.append((day, score))
            }
        }
        // Stable: equal scores keep reading order.
        return found.enumerated()
            .sorted { $0.element.score != $1.element.score ? $0.element.score > $1.element.score : $0.offset < $1.offset }
            .map(\.element)
    }

    static let monthNames = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

    static func looksLikeCalendarDate(_ text: String) -> Bool {
        let lowered = text.lowercased()
        guard lowered.contains(where: \.isNumber) else { return false }
        if monthNames.contains(where: lowered.contains) { return true }
        // 10/3/2026, 2026-10-03, 3.10.2026
        return lowered.contains(/\d{1,4}[\/\-.]\d{1,2}[\/\-.]\d{1,4}/)
    }

    /// "7-day free trial", "1-month free trial", "14 day trial" → today + that length.
    static func trialLengthDate(in text: String, now: Date, calendar: Calendar) -> Date? {
        let today = calendar.startOfDay(for: now)
        let length = #/(?<n>\d{1,2})[\s-]*(?<unit>day|week|month)s?\s+(?:free\s+)?trial/#.ignoresCase()
        if let match = text.firstMatch(of: length), let n = Int(match.output.n) {
            let component: Calendar.Component = switch match.output.unit.lowercased() {
            case "week": .weekOfYear
            case "month": .month
            default: .day
            }
            return calendar.date(byAdding: component, value: n, to: today)
        }
        return nil
    }

    // MARK: Apple

    public static func looksBilledByApple(_ text: String) -> Bool {
        let lowered = text.lowercased()
        return ["apple account", "confirm with side button", "double click to subscribe", "app store", "settings > apple", "apple one", "apple music", "apple tv", "icloud+"]
            .contains { lowered.contains($0) }
    }
}

private extension String {
    func slice(from start: Int, to end: Int) -> String {
        guard start < end, start >= 0, end <= count else { return "" }
        let lower = index(startIndex, offsetBy: start)
        let upper = index(startIndex, offsetBy: end)
        return String(self[lower..<upper])
    }
}
