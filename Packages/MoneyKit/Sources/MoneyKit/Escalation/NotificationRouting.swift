import Foundation
import UserNotifications

/// Shows reminder banners while the app is open, and sends a tapped reminder to the Decide screen.
public final class ForegroundNotificationPresenter: NSObject, UNUserNotificationCenterDelegate, Sendable {
    public static let shared = ForegroundNotificationPresenter()

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let raw = response.notification.request.content.userInfo[EscalationScheduler.itemIDKey] as? String,
              let itemID = UUID(uuidString: raw)
        else { return }
        await MainActor.run { DecideRouter.shared.request(itemID: itemID) }
    }
}
