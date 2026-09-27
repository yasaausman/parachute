// Renders the A7 fixture screenshots (synthetic: text laid out like real trial screens).
// Run from the repo root: swift Packages/MoneyKit/Fixtures/make-fixtures.swift
import AppKit
import Foundation

struct Fixture: Encodable {
    var file: String
    var dark: Bool
    var lines: [String]
    var expected: Expected
}

struct Expected: Encodable {
    var serviceName: String
    var amountCents: Int
    var chargeDate: String
    var billedByApple: Bool
}

// "Today" for every fixture is 2026-09-27 (see expected.json).
let fixtures: [Fixture] = [
    Fixture(file: "01-apple-one-sheet.png", dark: true, lines: [
        "9:41", "Apple One", "Individual", "Apple One 4+", "Subscription",
        "1-month free trial", "Starting today", "$21.95 per month", "Starting Oct 26, 2026",
        "No commitment. Cancel anytime in Settings > Apple Account", "at least a day before each renewal date.",
        "Account: someone@example.com", "Confirm with Side Button",
    ], expected: Expected(serviceName: "Apple One", amountCents: 2195, chargeDate: "2026-10-26", billedByApple: true)),
    Fixture(file: "02-spotify-email.png", dark: false, lines: [
        "Spotify", "Your Premium trial has started", "Enjoy 1 month of Premium for free.",
        "After your trial ends on October 26, 2026,", "you'll be charged $11.99/month.",
        "Cancel anytime in your account settings.", "Manage account",
    ], expected: Expected(serviceName: "Spotify", amountCents: 1199, chargeDate: "2026-10-26", billedByApple: false)),
    Fixture(file: "03-hulu-web.png", dark: false, lines: [
        "hulu", "Welcome to Hulu!", "Your free trial ends 10/3/2026.",
        "Starting then, you'll be billed $18.99 per month", "unless you cancel.", "$0.00 due today",
    ], expected: Expected(serviceName: "Hulu", amountCents: 1899, chargeDate: "2026-10-03", billedByApple: false)),
    Fixture(file: "04-google-one.png", dark: false, lines: [
        "Google One", "Google AI Pro (2 TB)", "Next payment: $19.99 on 7 Dec 2026",
        "Upcoming charges", "Starting 7 Dec 2026    $19.99/ month", "Cancel subscription",
    ], expected: Expected(serviceName: "Google One|Google AI Pro", amountCents: 1999, chargeDate: "2026-12-07", billedByApple: false)),
    Fixture(file: "05-duolingo-apple.png", dark: true, lines: [
        "Duolingo", "Super Duolingo", "14-day free trial", "Then $12.99/month",
        "Cancel anytime in Settings > Apple Account", "at least a day before each renewal date.", "Confirm with Side Button",
    ], expected: Expected(serviceName: "Duolingo", amountCents: 1299, chargeDate: "2026-10-11", billedByApple: true)),
    Fixture(file: "06-netflix-account.png", dark: true, lines: [
        "NETFLIX", "Membership & Billing", "Standard plan",
        "Your next billing date is November 2, 2026.", "Amount: $17.99", "Payment method: Visa •••• 0000",
    ], expected: Expected(serviceName: "Netflix", amountCents: 1799, chargeDate: "2026-11-02", billedByApple: false)),
    Fixture(file: "07-disney-email.png", dark: false, lines: [
        "Disney+", "Your 7-day free trial ends on Oct 4, 2026.",
        "You'll be charged $9.99 on Oct 4, 2026", "unless you cancel before then.",
    ], expected: Expected(serviceName: "Disney+", amountCents: 999, chargeDate: "2026-10-04", billedByApple: false)),
    Fixture(file: "08-adobe-checkout.png", dark: false, lines: [
        "Adobe Creative Cloud", "Free trial ends Oct 10, 2026",
        "After your trial: US$22.99/mo (annual, billed monthly)", "Today's total: US$0.00",
    ], expected: Expected(serviceName: "Adobe", amountCents: 2299, chargeDate: "2026-10-10", billedByApple: false)),
    Fixture(file: "09-audible-email.png", dark: false, lines: [
        "audible", "an Amazon company", "Your 30-day free trial is active.",
        "Your first charge of $14.95 will be on 10/27/2026.", "Cancel anytime.",
    ], expected: Expected(serviceName: "Audible", amountCents: 1495, chargeDate: "2026-10-27", billedByApple: false)),
    Fixture(file: "10-youtube-premium.png", dark: true, lines: [
        "YouTube Premium", "Your trial ends Oct 12, 2026.", "Then $13.99/month.",
        "Family plan available for $22.99/month.",
    ], expected: Expected(serviceName: "YouTube Premium", amountCents: 1399, chargeDate: "2026-10-12", billedByApple: false)),
]

let directory = URL(fileURLWithPath: "Packages/MoneyKit/Fixtures/TrialScreenshots", isDirectory: true)
let width = 1179, height = 1400

for fixture in fixtures {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    (fixture.dark ? NSColor(white: 0.08, alpha: 1) : NSColor.white).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()
    var y = CGFloat(height - 120)
    for (index, line) in fixture.lines.enumerated() {
        let size: CGFloat = index == 0 ? 64 : 44
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size, weight: index == 0 ? .bold : .regular),
            .foregroundColor: fixture.dark ? NSColor.white : NSColor.black,
        ]
        NSAttributedString(string: line, attributes: attributes).draw(at: NSPoint(x: 70, y: y))
        y -= size * 1.8
    }
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent(fixture.file))
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let expected = Dictionary(uniqueKeysWithValues: fixtures.map { ($0.file, $0.expected) })
try! encoder.encode(ExpectedFile(today: "2026-09-27", fixtures: expected)).write(to: directory.appendingPathComponent("expected.json"))
print("Wrote \(fixtures.count) fixtures to \(directory.path)")

struct ExpectedFile: Encodable {
    var today: String
    var fixtures: [String: Expected]
}
