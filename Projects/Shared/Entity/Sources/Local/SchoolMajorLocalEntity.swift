import Foundation
import GRDB

public struct SchoolMajorLocalEntity: Codable, FetchableRecord, PersistableRecord {
    public let id: String
    public let major: String

    public init(id: String = UUID().uuidString, major: String) {
        self.id = id
        self.major = major
    }
}
