import SwiftUI
import UIKit

/// Contrast-safe versions of `Theme` colors for ParachuteKit text and fills (P1). Theme's bright
/// cyan, green, and orange are ~2:1 against white; these pass WCAG AA (4.5:1) on white and
/// grouped backgrounds. Theme's colors stay fine on black (confetti, share card).
enum Palette {
    /// Behind white text (buttons, the Home card): white on #006E8C is 5.8:1.
    static let frozenFill = Color(red: 0, green: 0x6E / 255, blue: 0x8C / 255)

    /// Cyan text and icons: #006E8C in light mode (5.8:1 on white), #32D2F5 in dark (9.5:1 on #1C1C1E).
    static let frozenInk = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x32 / 255, green: 0xD2 / 255, blue: 0xF5 / 255, alpha: 1)
            : UIColor(red: 0, green: 0x6E / 255, blue: 0x8C / 255, alpha: 1)
    })

    /// Money text: #1E7A35 in light mode (5.4:1 on white), system green in dark (8.4:1).
    static let moneyInk = adaptive(light: (0x1E, 0x7A, 0x35), dark: (0x30, 0xD1, 0x58))

    /// Accent text (best run): #B35400 in light mode (5.0:1 on white), system orange in dark (8.3:1).
    static let accentInk = adaptive(light: (0xB3, 0x54, 0x00), dark: (0xFF, 0x9F, 0x0A))

    private static func adaptive(light: (Int, Int, Int), dark: (Int, Int, Int)) -> Color {
        func color(_ c: (Int, Int, Int)) -> UIColor {
            UIColor(red: CGFloat(c.0) / 255, green: CGFloat(c.1) / 255, blue: CGFloat(c.2) / 255, alpha: 1)
        }
        return Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? color(dark) : color(light) })
    }
}
