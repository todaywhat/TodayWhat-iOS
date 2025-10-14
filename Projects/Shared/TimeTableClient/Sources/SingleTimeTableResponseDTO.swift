import Entity
import Foundation

public struct SingleTimeTableResponseDTO: Decodable {
    public let perio: String
    public let content: String
    public let serviceDate: String

    enum CodingKeys: String, CodingKey {
        case perio = "PERIO"
        case content = "ITRT_CNTNT"
        case serviceDate = "ALL_TI_YMD"
    }
}

public extension SingleTimeTableResponseDTO {
    static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = .autoupdatingCurrent
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    func toDomain() -> TimeTable {
        let date = Self.dateFormatter.date(from: serviceDate)

        return .init(
            perio: Int(perio) ?? 1,
            content: content,
            date: date
        )
    }
}
