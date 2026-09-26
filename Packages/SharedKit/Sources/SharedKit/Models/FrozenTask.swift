import Foundation
import SwiftData

/// A deadline task the user froze on. Written by Dev B.
@Model
public final class FrozenTask {
    public var id: UUID
    /// "8-page history essay"
    public var title: String
    public var dueDate: Date?
    public var statusRaw: String
    @Relationship(deleteRule: .cascade) public var steps: [MicroStep]
    public var createdAt: Date

    public var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date? = nil,
        status: TaskStatus = .active,
        steps: [MicroStep] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.statusRaw = status.rawValue
        self.steps = steps
        self.createdAt = createdAt
    }
}

public enum TaskStatus: String, Codable, Sendable, CaseIterable {
    case active, done, abandoned
}
