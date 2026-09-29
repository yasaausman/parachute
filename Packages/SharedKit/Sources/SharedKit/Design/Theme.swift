import SwiftUI
import UIKit

/// Minimal design tokens. Grow this together; keep screens using these instead of raw values.
public enum Theme {
    public static let accent = Color.orange
    public static let money = Color.green
    public static let frozen = Color.cyan

    // Contrast-safe variants (WCAG AA, 4.5:1). `accent`/`money`/`frozen` are ~2:1 as text on white,
    // so use these for text, icons, and fills behind white text. The bright ones stay fine on black
    // (confetti, the share card) and as light tinted backgrounds.

    /// Money text: #1E7A35 light (5.4:1 on white), #30D158 dark (8.4:1 on #1C1C1E).
    public static let moneyText = adaptive(light: (0x1E, 0x7A, 0x35), dark: (0x30, 0xD1, 0x58))
    /// Accent text: #B35400 light (5.0:1), #FF9F0A dark (8.3:1).
    public static let accentText = adaptive(light: (0xB3, 0x54, 0x00), dark: (0xFF, 0x9F, 0x0A))
    /// Frozen text and icons: #006E8C light (5.8:1), #32D2F5 dark (9.5:1).
    public static let frozenText = adaptive(light: (0x00, 0x6E, 0x8C), dark: (0x32, 0xD2, 0xF5))
    /// Behind white text (buttons, cards): white on #006E8C is 5.8:1.
    public static let frozenFill = Color(red: 0, green: 0x6E / 255, blue: 0x8C / 255)
    /// Urgent text (≤ 1 day): #C4281C light (5.6:1), #FF453A dark.
    public static let urgentText = adaptive(light: (0xC4, 0x28, 0x1C), dark: (0xFF, 0x45, 0x3A))

    public static let cornerRadius: CGFloat = 16
    public static let spacing: CGFloat = 16

    private static func adaptive(light: (Int, Int, Int), dark: (Int, Int, Int)) -> Color {
        func color(_ c: (Int, Int, Int)) -> UIColor {
            UIColor(red: CGFloat(c.0) / 255, green: CGFloat(c.1) / 255, blue: CGFloat(c.2) / 255, alpha: 1)
        }
        return Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? color(dark) : color(light) })
    }
}

public extension Int {
    /// 1799 → "$17.99" in the given currency.
    func formattedCents(currencyCode: String = "USD") -> String {
        (Decimal(self) / 100).formatted(.currency(code: currencyCode))
    }
}
