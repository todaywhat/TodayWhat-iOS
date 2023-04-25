import Foundation
import Entity

public struct SingleTimeTableResponseDTO: Decodable {
    public let date: String
    public let perio: String
    public let content: String
    
    enum CodingKeys: String, CodingKey {
        case date = "ALL_TI_YMD"
        case perio = "PERIO"
        case content = "ITRT_CNTNT"
    }
}

public extension SingleTimeTableResponseDTO {
    func toDomain() -> TimeTable {
        return .init(
            date: date,
            perio: Int(perio) ?? 1,
            content: content
        )
    }
}
