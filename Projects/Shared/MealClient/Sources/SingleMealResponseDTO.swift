import Entity
import EnumUtil
import Foundation

public struct SingleMealResponseDTO: Decodable {
    public let info: String
    public let type: MealType
    public let calInfo: String
    public let serviceDate: String

    public init(info: String, type: MealType, calInfo: String, serviceDate: String) {
        self.info = info
        self.type = type
        self.calInfo = calInfo
        self.serviceDate = serviceDate
    }

    enum CodingKeys: String, CodingKey {
        case info = "DDISH_NM"
        case type = "MMEAL_SC_NM"
        case calInfo = "CAL_INFO"
        case serviceDate = "MLSV_YMD"
    }
}
