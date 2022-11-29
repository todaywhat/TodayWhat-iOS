import Foundation

public enum MealType: String, Decodable {
    case breakfast = "조식"
    case lunch = "중식"
    case dinner = "석식"

    public var display: String {
        switch self {
        case .breakfast:
            return "아침"

        case .lunch:
            return "점심"

        case .dinner:
            return "저녁"
        }
    }

    public var watchDisplay: String {
        switch self {
        case .breakfast:
            return "🥞 아침"

        case .lunch:
            return "🍱 점심"

        case .dinner:
            return "🍛 저녁"
        }
    }
}
