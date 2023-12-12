import DateUtil
import Foundation
import UserDefaultsClient

enum MealPartTime {
    case breakfast
    case lunch
    case dinner

    var display: String {
        switch self {
        case .breakfast:
            return "아침"

        case .lunch:
            return "점심"

        case .dinner:
            return "저녁"
        }
    }

    init(hour: Date) {
        if !UserDefaults.app.bool(forKey: UserDefaultsKeys.isSkipWeekend.rawValue) &&
            (hour.weekday == 7 || hour.weekday == 1) {
            self = .breakfast
            return
        }
        switch hour.hour {
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
