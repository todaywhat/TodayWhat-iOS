import Foundation
import GRDB

public struct MealLocalEntity: Codable, FetchableRecord, PersistableRecord {
    public let date: Date
}
