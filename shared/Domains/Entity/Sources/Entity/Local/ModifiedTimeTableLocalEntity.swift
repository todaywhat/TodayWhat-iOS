import Foundation
import GRDB

public struct ModifiedTimeTableLocalEntity: Codable, FetchableRecord, PersistableRecord, Equatable {
    public let id: String
    public let weekday: Int
    public let perio: Int
    public let content: String

    public init(id: String, weekday: Int, perio: Int, content: String) {
        self.id = id
        self.weekday = weekday
        self.perio = perio
        self.content = content
    }
}

