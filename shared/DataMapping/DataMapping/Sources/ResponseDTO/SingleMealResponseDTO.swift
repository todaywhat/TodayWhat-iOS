import Foundation
import Entity
import EnumUtil

public struct SingleMealResponseDTO: Decodable {
    public let info: String
    public let type: MealType

    public init(info: String, type: MealType) {
        self.info = info
        self.type = type
    }
}
