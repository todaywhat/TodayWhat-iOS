import AppIntents

@available(iOS 16, *)
struct TodayWhatAppOpenIntent: OpenIntent {
    static let title: LocalizedStringResource = "오늘 급식/시간표 보러가기"
    static let description = IntentDescription("오늘뭐임 앱 열기")

    static var openAppWhenRun: Bool = true

    @Parameter(title: "화면 위치", default: .home)
    var target: TodayWhatAppOpenControlAppEnum

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

@available(iOS 16, *)
enum TodayWhatAppOpenControlAppEnum: String, AppEnum {
    case home

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "홈")

    static let caseDisplayRepresentations: [TodayWhatAppOpenControlAppEnum: DisplayRepresentation] = [
        .home: "Home"
    ]
}
