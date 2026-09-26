import Foundation

/// Prints and records calls. Swap for MoneyKit's real scheduler once A2/A4 land.
public actor FakeEscalationScheduler: EscalationScheduling {
    public enum Call: Sendable, Hashable {
        case schedule(itemID: UUID, title: String, due: Date, kind: EscalationKind)
        case snooze(itemID: UUID, until: Date)
        case resolve(itemID: UUID)
    }

    public private(set) var calls: [Call] = []

    public init() {}

    public func schedule(itemID: UUID, title: String, due: Date, kind: EscalationKind) async throws {
        log(.schedule(itemID: itemID, title: title, due: due, kind: kind))
    }

    public func snooze(itemID: UUID, until: Date) async throws {
        log(.snooze(itemID: itemID, until: until))
    }

    public func resolve(itemID: UUID) async {
        log(.resolve(itemID: itemID))
    }

    private func log(_ call: Call) {
        print("[FakeEscalationScheduler] \(call)")
        calls.append(call)
    }
}
