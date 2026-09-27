import Foundation
import Observation
import SharedKit

/// The app's one modal slot. Swapping `sheet` from `.decide` to `.unfreeze` lets
/// "I'm frozen" hand off from A's Decide screen to B's Unfreeze player (docs/interfaces.md §3).
@MainActor
@Observable
final class SheetRouter {
    enum Sheet: Identifiable {
        case decide(itemID: UUID)
        case unfreeze(UnfreezeRequest, itemID: UUID?)
        case paywall

        var id: String {
            switch self {
            case .paywall: "paywall"
            case .decide(let itemID): "decide-\(itemID)"
            case .unfreeze(_, let itemID): "unfreeze-\(itemID?.uuidString ?? "task")"
            }
        }
    }

    var sheet: Sheet?
}
