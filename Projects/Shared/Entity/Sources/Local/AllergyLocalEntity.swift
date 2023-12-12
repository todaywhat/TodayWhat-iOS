import Foundation
import GRDB

public struct AllergyLocalEntity: Codable, FetchableRecord, PersistableRecord {
    public let id: String
    public let allergy: String

    public init(id: String = UUID().uuidString, allergy: String) {
        self.id = id
        self.allergy = allergy
    }
}
