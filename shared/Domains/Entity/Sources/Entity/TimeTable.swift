import Foundation

public struct TimeTable: Equatable, Hashable {
    public let perio: Int
    public let content: String

    public init(perio: Int, content: String) {
        self.perio = perio
        self.content = content
    }
}
