import Foundation

/// The cancel path for trials billed by Apple (CLAUDE.md rule 8). Used by A's "Cancel it"
/// screen (A6) and B's Unfreeze engine (B3, `StepSource.appleSubscriptions`).
public enum AppleSubscriptions {
    /// Opens the Subscriptions page on iPhone, with a back button to Parachute. Not documented on an
    /// Apple page (checked 2026-09-27), but confirmed on an iPhone on iOS 27 (2026-09-28). `steps` stay as a fallback.
    public static let manageURL = URL(string: "https://apps.apple.com/account/subscriptions")!

    /// Apple's own web page for the same thing, linked from Apple Support 118428
    /// ("Cancel a subscription from Apple on the web").
    public static let webURL = URL(string: "https://account.apple.com/account/manage/section/subscriptions")!

    /// Apple Support 118428, "Cancel a subscription on your iPhone", split into ≤ 90 s steps.
    public static func steps(serviceName: String) -> [PlanStep] {
        [
            PlanStep(text: "Open Settings and tap your name at the top.", seconds: 20),
            PlanStep(text: "Tap 'Subscriptions'.", seconds: 10),
            PlanStep(text: "Tap '\(serviceName)'.", seconds: 15),
            PlanStep(text: "Tap 'Cancel Subscription' (or 'Cancel Free Trial'). You might need to scroll down. Then confirm.", seconds: 30),
        ]
    }
}
