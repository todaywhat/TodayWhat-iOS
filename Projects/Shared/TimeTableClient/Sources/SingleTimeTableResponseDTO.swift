import Entity
import Foundation

public struct SingleTimeTableResponseDTO: Decodable {
    public let perio: String
    public let content: String

    enum CodingKeys: String, CodingKey {
        case perio = "PERIO"
        case content = "ITRT_CNTNT"
    }
}

public extension SingleTimeTableResponseDTO {
    func toDomain() -> TimeTable {
        return .init(
            perio: Int(perio) ?? 1,
            content: content
        )
    }
}
