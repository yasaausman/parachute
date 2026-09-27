import SwiftUI

public extension EnvironmentValues {
    /// The scoreboard ledger, injected by the app (fake until B6). Nil in previews.
    @Entry var completionLedger: (any CompletionLedger)?
}
