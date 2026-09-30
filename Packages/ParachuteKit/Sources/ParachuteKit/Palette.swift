import SharedKit
import SwiftUI

/// ParachuteKit's names for SharedKit's contrast-safe `Theme` colors (P1).
enum Palette {
    static let frozenFill = Theme.frozenFill
    static let frozenInk = Theme.frozenText
    static let moneyInk = Theme.moneyText
    static let accentInk = Theme.accentText
    static let tickEmpty = Theme.inkMuted.opacity(0.3)
}
