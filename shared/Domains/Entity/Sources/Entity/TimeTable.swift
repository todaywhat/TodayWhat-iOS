import Foundation

public struct TimeTable: Equatable, Hashable {
    public let date: String
    public let perio: Int
    public let content: String

    public init(date: String, perio: Int, content: String) {
        self.date = date
        self.perio = perio
        self.content = content
    }
}
