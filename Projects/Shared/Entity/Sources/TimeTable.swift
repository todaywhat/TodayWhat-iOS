import Foundation

public struct TimeTable: Equatable, Hashable {
    public let perio: Int
    public let content: String
    public let date: Date?

    public init(perio: Int, content: String, date: Date? = nil) {
        self.perio = perio
        self.content = content
        self.date = date
    }
}
