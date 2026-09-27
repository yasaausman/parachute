// A7 eval: OCR + extraction on the fixture screenshots, scored field by field.
// Run: swift run --package-path Packages/MoneyKit TrialCaptureEval Packages/MoneyKit/Fixtures/TrialScreenshots
import Foundation
import ImageIO
import TrialCapture

struct Expected: Decodable {
    var serviceName: String
    var amountCents: Int
    var chargeDate: String
    var billedByApple: Bool
}

struct ExpectedFile: Decodable {
    var today: String
    var fixtures: [String: Expected]
}

let directory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Packages/MoneyKit/Fixtures/TrialScreenshots")
let file = try JSONDecoder().decode(ExpectedFile.self, from: Data(contentsOf: directory.appendingPathComponent("expected.json")))
let calendar = Calendar.current
let dayFormat = Date.ISO8601FormatStyle().year().month().day()
let now = calendar.date(byAdding: .hour, value: 12, to: try dayFormat.parse(file.today))!
// The curated services' short names (CancelSteps.json), as the app passes them.
let known = ["Spotify", "Claude", "Google AI Pro", "Apple One"]

func day(_ date: Date?) -> String {
    guard let date else { return "-" }
    let c = calendar.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
}

for useAI in [false, true] {
    if useAI && !AIExtractor.isAvailable {
        print("\nAI: Apple Intelligence unavailable on this Mac, skipped")
        continue
    }
    print("\n=== \(useAI ? "AI + patterns" : "patterns only (no AI)") ===")
    var fullyCorrect = 0
    for name in file.fixtures.keys.sorted() {
        let expected = file.fixtures[name]!
        let data = try Data(contentsOf: directory.appendingPathComponent(name))
        let source = CGImageSourceCreateWithData(data as CFData, nil)!
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        let (_, got) = try await TrialExtractor.extract(fromImage: image, now: now, knownServices: known, useAI: useAI)
        let checks = [
            // "A|B": either name is right (e.g. "Google One|Google AI Pro", same subscription).
            ("name", expected.serviceName.lowercased().split(separator: "|").contains { $0 == (got.serviceName?.lowercased() ?? "")[...] }, got.serviceName ?? "-"),
            ("amount", (got.amountCents ?? 0) == expected.amountCents, got.amountCents.map(String.init) ?? "-"),
            ("date", day(got.chargeDate) == expected.chargeDate, day(got.chargeDate)),
            ("apple", got.billedByApple == expected.billedByApple, String(got.billedByApple)),
        ]
        let ok = checks.allSatisfy(\.1)
        if ok { fullyCorrect += 1 }
        let misses = checks.filter { !$0.1 }.map { "\($0.0)=\($0.2)" }.joined(separator: " ")
        print("\(ok ? "✅" : "❌") \(name) [\(got.source.rawValue)]\(misses.isEmpty ? "" : "  wrong: \(misses)")")
        if useAI && CommandLine.arguments.contains("--verbose") {
            let text = try await TextRecognizer.text(in: image)
            print("   OCR: \(text.replacingOccurrences(of: "\n", with: " | "))")
            print("   AI:  \(await AIExtractor.debugDescription(for: text, now: now))")
        }
    }
    print("Fully correct: \(fullyCorrect)/\(file.fixtures.count)")
}
