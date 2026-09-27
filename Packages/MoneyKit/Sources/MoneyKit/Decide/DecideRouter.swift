import Foundation
import Observation

/// Where "Decide" (alarm button or reminder tap) sends the user. The app presents
/// `DecideView` for `pending`.
@MainActor
@Observable
public final class DecideRouter {
    public static let shared = DecideRouter()

    public struct Request: Identifiable, Hashable, Sendable {
        public var itemID: UUID
        public var id: UUID { itemID }
    }

    public var pending: Request?

    public func request(itemID: UUID) {
        pending = Request(itemID: itemID)
    }
}
