import Foundation

public enum WeekdayType: Int, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1

    public init(weekday: Int) {
        switch weekday {
        case 1:
            self = .sunday

        case 2...7:
            self = WeekdayType.allCases[weekday - 2]

        default:
            self = .monday
        }
    }
}

public extension WeekdayType {
    var analyticsValue: String {
        switch self {
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .saturday: return "토"
        case .sunday: return "일"
        }
    }
}
