import Foundation

enum DisplayInfoType: CaseIterable {
    case breakfast
    case lunch
    case dinner
    case timetable
    case settings
}

extension DisplayInfoType {
    var display: String {
        switch self {
        case .breakfast:
            return "🥞 아침"

        case .lunch:
            return "🍱 점심"

        case .dinner:
            return "🍛 저녁"

        case .timetable:
            return "⏰ 시간표"

        case .settings:
            return "⚙️ 설정"
        }
    }
}
