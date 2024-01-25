import Entity
import EnumUtil
import Foundation

public struct SingleMealResponseDTO: Decodable {
    public let info: String
    public let type: MealType
    public let calInfo: String

    public init(info: String, type: MealType, calInfo: String) {
        self.info = info
        self.type = type
        self.calInfo = calInfo
    }

    enum CodingKeys: String, CodingKey {
        case info = "DDISH_NM"
        case type = "MMEAL_SC_NM"
        case calInfo = "CAL_INFO"
    }
}
