import Foundation
import GRDB

public struct TimeTableLocalEntity: Codable, FetchableRecord, PersistableRecord {
    public let id: String
    public let date: String // yyyyMMdd format
    public let timeTableData: String // JSON array of TimeTableItem
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        date: String,
        timeTableData: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.timeTableData = timeTableData
        self.createdAt = createdAt
    }

    public static func persistenceKey(for date: String) -> String {
        return date
    }

    public static var databaseTableName: String {
        return "timeTableLocalEntity"
    }
}

// Helper structure for JSON serialization
private struct TimeTableItem: Codable {
    let perio: Int
    let content: String
}

public extension TimeTableLocalEntity {
    init(date: String, timeTables: [TimeTable]) {
        let encoder = JSONEncoder()
        let items = timeTables.map { TimeTableItem(perio: $0.perio, content: $0.content) }
        let jsonString = (try? String(data: encoder.encode(items), encoding: .utf8)) ?? "[]"

        self.init(
            date: date,
            timeTableData: jsonString
        )
    }

    private static let dateOnlyFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter.locale = .autoupdatingCurrent
        return dateFormatter
    }()

    func toTimeTables() -> [TimeTable] {
        let decoder = JSONDecoder()
        guard let items = try? decoder.decode([TimeTableItem].self, from: Data(timeTableData.utf8)) else {
            return []
        }

        let dateObject = Self.dateOnlyFormatter.date(from: date)

        return items.map { item in
            TimeTable(
                perio: item.perio,
                content: item.content,
                date: dateObject
            )
        }
    }
}
