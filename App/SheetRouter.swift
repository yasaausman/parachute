import Foundation
import Observation
import SharedKit

/// The app's modals. Decide and the paywall are sheets; B's Unfreeze player is full screen
/// (docs/interfaces.md, "As implemented (B)"). "Get unstuck" swaps the Decide sheet for the player.
@MainActor
@Observable
final class SheetRouter {
    enum Sheet: Identifiable {
        case decide(itemID: UUID)
        case paywall

        var id: String {
            switch self {
            case .decide(let itemID): "decide-\(itemID)"
            case .paywall: "paywall"
            }
        }
    }

    struct Frozen: Identifiable {
        var request: UnfreezeRequest
        var itemID: UUID?
        var id: String { "unfreeze-\(itemID?.uuidString ?? "task")" }
    }

    var sheet: Sheet?
    var frozen: Frozen?

    /// Closes the Decide sheet, then opens the player once the sheet is gone.
    func unfreeze(_ request: UnfreezeRequest, itemID: UUID?) {
        sheet = nil
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            frozen = Frozen(request: request, itemID: itemID)
        }
    }
}
