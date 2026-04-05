import AppIntents
import AppRouteClient

@available(iOS 16.0, macOS 13.0, *)
struct TodayWhatAppOpenIntent: OpenIntent {
    static let title: LocalizedStringResource = "오늘뭐임 열기"
    static let description = IntentDescription("오늘뭐임 앱을 원하는 화면으로 엽니다")

    static var openAppWhenRun: Bool = true

    @AppDependency
    private var routeStore: TodayWhatAppRouteStore

    @Parameter(title: "화면", default: .home)
    var target: TodayWhatAppOpenControlAppEnum

    init() {
        self.target = .home
    }

    init(target: TodayWhatAppOpenControlAppEnum) {
        self.target = target
    }

    func perform() async throws -> some IntentResult {
        await routeStore.request(target.route)
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, *)
enum TodayWhatAppOpenControlAppEnum: String, AppEnum {
    case home
    case meal
    case timetable

    var route: TodayWhatAppRoute {
        switch self {
        case .home: .home
        case .meal: .meal
        case .timetable: .timetable
        }
    }

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "화면")

    static let caseDisplayRepresentations: [TodayWhatAppOpenControlAppEnum: DisplayRepresentation] = [
        .home: "홈",
        .meal: "급식",
        .timetable: "시간표"
    ]
}
