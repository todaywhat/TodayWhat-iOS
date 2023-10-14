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

    public init(hour: Date, isSkipWeekend: Bool = false) {
        let weekday = Calendar.current.component(.weekday, from: hour)
        let hourTime = Calendar.current.component(.hour, from: hour)

        if isSkipWeekend && weekday.isWeekend {
            self = .breakfast
            return
        }
        switch hourTime {
        case 0..<8:
            self = .breakfast

        case 8..<13:
            self = .lunch

        case 13..<20:
            self = .dinner

        default:
            self = .breakfast
        }
    }
}

private extension Int {
    var isWeekend: Bool {
        self == 7 || self == 1
    }
}
