import Foundation

public struct Notice: Equatable {
    public let id: String
    public let title: String
    public let content: String
    public let createdAt: Date

    public init(id: String, title: String, content: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
    }
}
