import Foundation

public struct Meal: Equatable, Hashable {
    public let breakfast: [String]
    public let lunch: [String]
    public let dinner: [String]

    public init(breakfast: [String], lunch: [String], dinner: [String]) {
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
    }
}
