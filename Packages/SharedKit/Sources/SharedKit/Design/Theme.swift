import SwiftUI
import UIKit

/// Untax design tokens (docs/brand/BRAND.md). Keep screens using these instead of raw values.
/// One accent (coral) on warm neutrals; `money` green only ever means money back, `frozen` teal only
/// ever means Unfreeze mode.
public enum Theme {
    // MARK: Neutrals

    /// Background: warm paper #FAF7F2 / #141210.
    public static let paper = adaptive(light: (0xFA, 0xF7, 0xF2), dark: (0x14, 0x12, 0x10))
    /// Raised surfaces (cards, receipt): #FFFFFF / #1F1C19.
    public static let surface = adaptive(light: (0xFF, 0xFF, 0xFF), dark: (0x1F, 0x1C, 0x19))
    /// Primary text: #1A1714 / #F2EEE8 (16.7:1).
    public static let ink = adaptive(light: (0x1A, 0x17, 0x14), dark: (0xF2, 0xEE, 0xE8))
    /// Secondary text: #6B645C / #A39B91 (5.5:1 / 6.2:1).
    public static let inkMuted = adaptive(light: (0x6B, 0x64, 0x5C), dark: (0xA3, 0x9B, 0x91))
    /// The single hairline used for elevation: ink at 8–14%.
    public static let hairline = adaptive(light: (0x1A, 0x17, 0x14), dark: (0xF2, 0xEE, 0xE8)).opacity(0.1)

    // MARK: Brand and meaning colors

    /// Brand coral #E8472B. Icon field, confetti, tints, big display. Not for small text on paper.
    public static let accent = Color(red: 0xE8 / 255, green: 0x47 / 255, blue: 0x2B / 255)
    /// Bright money green (confetti, share card on black, tinted backgrounds).
    public static let money = Color(red: 0x30 / 255, green: 0xD1 / 255, blue: 0x58 / 255)
    /// Bright Unfreeze teal (tinted backgrounds, on black).
    public static let frozen = Color(red: 0x32 / 255, green: 0xD2 / 255, blue: 0xF5 / 255)

    // Contrast-safe variants (WCAG AA, 4.5:1) for text, icons, and fills behind white text.

    /// Money text: #1E7A35 light (5.1:1 on paper), #30D158 dark (8.4:1).
    public static let moneyText = adaptive(light: (0x1E, 0x7A, 0x35), dark: (0x30, 0xD1, 0x58))
    /// Accent text: #C2381F light (5.1:1 on paper), #FF7A5C dark (6.6:1).
    public static let accentText = adaptive(light: (0xC2, 0x38, 0x1F), dark: (0xFF, 0x7A, 0x5C))
    /// Behind white text (primary buttons, badges): white on #C2381F is 5.4:1 in both modes.
    public static let accentFill = Color(red: 0xC2 / 255, green: 0x38 / 255, blue: 0x1F / 255)
    /// Frozen text and icons: #006E8C light (5.4:1), #32D2F5 dark (9.4:1).
    public static let frozenText = adaptive(light: (0x00, 0x6E, 0x8C), dark: (0x32, 0xD2, 0xF5))
    /// Behind white text (buttons, cards): white on #006E8C is 5.8:1.
    public static let frozenFill = Color(red: 0, green: 0x6E / 255, blue: 0x8C / 255)
    /// Urgent text (≤ 1 day): #C4281C light (5.6:1), #FF453A dark.
    public static let urgentText = adaptive(light: (0xC4, 0x28, 0x1C), dark: (0xFF, 0x45, 0x3A))

    // MARK: Shape and space (8pt grid)

    public static let cornerRadius: CGFloat = 14
    public static let spacing: CGFloat = 16
    public static let screenPadding: CGFloat = 20
    public static let buttonHeight: CGFloat = 54

    // MARK: Type (system faces, Dynamic Type preserved)

    /// Screen titles and the big moments. Rounded heavy.
    public static func display(_ style: Font.TextStyle = .largeTitle) -> Font {
        .system(style, design: .rounded, weight: .heavy)
    }
    /// Card titles, player step text. Rounded bold.
    public static func headline(_ style: Font.TextStyle = .title3) -> Font {
        .system(style, design: .rounded, weight: .bold)
    }
    /// Dollar amounts, countdowns, receipt lines. Pair with `.monospacedDigit()` where numbers change.
    public static func number(_ style: Font.TextStyle = .title) -> Font {
        .system(style, design: .monospaced, weight: .semibold)
    }

    private static func adaptive(light: (Int, Int, Int), dark: (Int, Int, Int)) -> Color {
        func color(_ c: (Int, Int, Int)) -> UIColor {
            UIColor(red: CGFloat(c.0) / 255, green: CGFloat(c.1) / 255, blue: CGFloat(c.2) / 255, alpha: 1)
        }
        return Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? color(dark) : color(light) })
    }
}

// MARK: - Button styles

/// Full-width 54pt rounded button. `.primary` = coral fill, `.frozen` = teal fill, `.quiet` = hairline outline.
public struct UntaxButtonStyle: ButtonStyle {
    public enum Kind: Sendable { case primary, frozen, quiet }
    let kind: Kind
    public init(_ kind: Kind = .primary) { self.kind = kind }

    public func makeBody(configuration: Configuration) -> some View {
        UntaxButtonBody(kind: kind, configuration: configuration)
    }
}

private struct UntaxButtonBody: View {
    let kind: UntaxButtonStyle.Kind
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(Theme.headline(.headline))
            .frame(maxWidth: .infinity, minHeight: Theme.buttonHeight)
            .padding(.horizontal, Theme.spacing)
            .foregroundStyle(kind == .quiet ? Theme.ink : .white)
            .background(fill, in: .rect(cornerRadius: Theme.cornerRadius))
            .overlay {
                if kind == .quiet {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius).strokeBorder(Theme.hairline, lineWidth: 1.5)
                }
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.45)
            .contentShape(.rect(cornerRadius: Theme.cornerRadius))
    }

    private var fill: Color {
        switch kind {
        case .primary: Theme.accentFill
        case .frozen: Theme.frozenFill
        case .quiet: Theme.surface
        }
    }
}

public extension ButtonStyle where Self == UntaxButtonStyle {
    static var untax: UntaxButtonStyle { UntaxButtonStyle(.primary) }
    static var untaxFrozen: UntaxButtonStyle { UntaxButtonStyle(.frozen) }
    static var untaxQuiet: UntaxButtonStyle { UntaxButtonStyle(.quiet) }
}

// MARK: - Surfaces

public extension View {
    /// The one elevation: surface fill + hairline border, radius 14. No shadow.
    func untaxCard(padding: CGFloat = Theme.spacing) -> some View {
        self.padding(padding)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).strokeBorder(Theme.hairline, lineWidth: 1))
    }

    /// Warm paper background for a whole screen (behind lists and scroll views).
    func untaxScreen() -> some View {
        self.scrollContentBackground(.hidden).background(Theme.paper.ignoresSafeArea())
    }
}

/// A receipt: square top corners rounded slightly, a torn zigzag bottom edge. Scoreboard and share card only.
public struct ReceiptShape: Shape {
    public var tooth: CGFloat
    public init(tooth: CGFloat = 10) { self.tooth = tooth }

    public func path(in rect: CGRect) -> Path {
        var p = Path()
        let r: CGFloat = 6
        let bottom = rect.maxY - tooth
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r), control: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: bottom))
        let count = max(1, Int((rect.width / (tooth * 2)).rounded()))
        let step = rect.width / CGFloat(count)
        for i in (0..<count).reversed() {
            let x = rect.minX + CGFloat(i) * step
            p.addLine(to: CGPoint(x: x + step / 2, y: rect.maxY))
            p.addLine(to: CGPoint(x: x, y: bottom))
        }
        p.closeSubpath()
        return p
    }
}

public extension Int {
    /// 1799 → "$17.99" in the given currency.
    func formattedCents(currencyCode: String = "USD") -> String {
        (Decimal(self) / 100).formatted(.currency(code: currencyCode))
    }
}
