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
