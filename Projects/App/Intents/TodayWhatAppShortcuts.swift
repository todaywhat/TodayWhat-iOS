import AppIntents

@available(iOS 16, macOS 13, *)
struct TodayWhatAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetMealIntent(mealTime: .all, daySelection: .today),
            phrases: [
                "\(.applicationName) 오늘 급식",
                "오늘 \(.applicationName) 급식",
                "\(.applicationName)에서 오늘 급식 보여줘"
            ],
            shortTitle: "오늘 급식",
            systemImageName: "fork.knife"
        )

        AppShortcut(
            intent: GetMealIntent(mealTime: .breakfast, daySelection: .today),
            phrases: [
                "\(.applicationName) 오늘 아침 급식",
                "오늘 \(.applicationName) 아침 급식",
                "\(.applicationName)에서 오늘 아침 급식 보여줘"
            ],
            shortTitle: "오늘 아침 급식",
            systemImageName: "sunrise"
        )

        AppShortcut(
            intent: GetMealIntent(mealTime: .lunch, daySelection: .today),
            phrases: [
                "\(.applicationName) 오늘 점심 급식",
                "오늘 \(.applicationName) 점심 급식",
                "\(.applicationName)에서 오늘 점심 급식 보여줘"
            ],
            shortTitle: "오늘 점심 급식",
            systemImageName: "sun.max"
        )

        AppShortcut(
            intent: GetMealIntent(mealTime: .dinner, daySelection: .today),
            phrases: [
                "\(.applicationName) 오늘 저녁 급식",
                "오늘 \(.applicationName) 저녁 급식",
                "\(.applicationName)에서 오늘 저녁 급식 보여줘"
            ],
            shortTitle: "오늘 저녁 급식",
            systemImageName: "moon.stars"
        )

        AppShortcut(
            intent: GetMealIntent(mealTime: .all, daySelection: .tomorrow),
            phrases: [
                "\(.applicationName) 내일 급식",
                "내일 \(.applicationName) 급식",
                "\(.applicationName)에서 내일 급식 보여줘"
            ],
            shortTitle: "내일 급식",
            systemImageName: "fork.knife"
        )

        AppShortcut(
            intent: GetMealIntent(mealTime: .breakfast, daySelection: .tomorrow),
            phrases: [
                "\(.applicationName) 내일 아침 급식",
                "내일 \(.applicationName) 아침 급식",
                "\(.applicationName)에서 내일 아침 급식 보여줘"
            ],
            shortTitle: "내일 아침 급식",
            systemImageName: "sunrise"
        )

        AppShortcut(
            intent: GetMealIntent(mealTime: .lunch, daySelection: .tomorrow),
            phrases: [
                "\(.applicationName) 내일 점심 급식",
                "내일 \(.applicationName) 점심 급식",
                "\(.applicationName)에서 내일 점심 급식 보여줘"
            ],
            shortTitle: "내일 점심 급식",
            systemImageName: "sun.max"
        )

        AppShortcut(
            intent: GetMealIntent(mealTime: .dinner, daySelection: .tomorrow),
            phrases: [
                "\(.applicationName) 내일 저녁 급식",
                "내일 \(.applicationName) 저녁 급식",
                "\(.applicationName)에서 내일 저녁 급식 보여줘"
            ],
            shortTitle: "내일 저녁 급식",
            systemImageName: "moon.stars"
        )

        AppShortcut(
            intent: GetTimeTableIntent(daySelection: .today),
            phrases: [
                "\(.applicationName) 오늘 시간표",
                "오늘 \(.applicationName) 시간표",
                "\(.applicationName)에서 오늘 시간표 보여줘"
            ],
            shortTitle: "오늘 시간표",
            systemImageName: "calendar"
        )

        AppShortcut(
            intent: GetTimeTableIntent(daySelection: .tomorrow),
            phrases: [
                "\(.applicationName) 내일 시간표",
                "내일 \(.applicationName) 시간표",
                "\(.applicationName)에서 내일 시간표 보여줘"
            ],
            shortTitle: "내일 시간표",
            systemImageName: "calendar"
        )
    }
}
