import Foundation

public struct WidgetReperesentation: Sendable, Equatable, Hashable {
    public enum WidgetKindType: Sendable {
        case meal
        case timetable
        case mealAndTimetable

        var title: String {
            switch self {
            case .meal: return "급식"
            case .timetable: return "시간표"
            case .mealAndTimetable: return "급식 & 시간표"
            }
        }
    }

    public enum WidgetFamilyType: Sendable {
        case systemSmall
        case systemMedium
        case systemLarge
        case systemExtraLarge
        case accessory
        case accessoryRectangular
        case accessoryCircular
        case controlCenter

        var title: String {
            switch self {
            case .systemSmall: return "홈화면 : 1 x 1"
            case .systemMedium: return "홈화면 : 2 x 1"
            case .systemLarge: return "홈화면 : 2 x 2"
            case .systemExtraLarge: return "홈화면 : 4 x 2"
            case .accessory: return "잠금화면"
            case .accessoryRectangular: return "잠금화면 : 2 x 1"
            case .accessoryCircular: return "잠금화면 : 1 x 1"
            case .controlCenter: return "제어센터"
            }
        }
    }

    public let id: String
    public let kind: WidgetKindType
    public let family: WidgetFamilyType

    init(id: String = UUID().uuidString, kind: WidgetKindType, family: WidgetFamilyType) {
        self.id = id
        self.kind = kind
        self.family = family
    }
}
