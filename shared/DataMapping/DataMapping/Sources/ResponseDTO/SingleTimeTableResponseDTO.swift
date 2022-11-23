import Foundation
import Entity

public struct TimeTableResponseDTO: Decodable {
    public let perio: String
    public let content: String
    
    enum CodingKeys: String, CodingKey {
        case perio = "PERIO"
        case content = "ITRT_CNTNT"
    }
}

public extension TimeTableResponseDTO {
    func toDomain() -> TimeTable {
        return .init(
            perio: Int(perio) ?? 1,
            content: content
        )
    }
}
