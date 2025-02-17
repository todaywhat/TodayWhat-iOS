import AppIntents
import WidgetKit

enum PartTimeIntentUserDefaultsKeys: Sendable {
    static let mealPartTime = "MEAL_PART_TIME"
    static let latestSelectedDate = "LATEST_MEAL_PART_TIME_SELECTED_DATE"
}

@available(iOS 16, *)
struct MealPartTimeSelectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Meal 조회 시간대 Intent"

    @Parameter(title: "Meal 조회 시간대")
    var displayMeal: MealPartTime

    init() {}

    init(displayMeal: MealPartTime) {
        self.displayMeal = displayMeal
    }

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(
            Date().timeIntervalSince1970,
            forKey: PartTimeIntentUserDefaultsKeys.latestSelectedDate
        )
        UserDefaults.standard.set(displayMeal.rawValue, forKey: PartTimeIntentUserDefaultsKeys.mealPartTime)
        WidgetCenter.shared.reloadTimelines(ofKind: "TodayWhatMealWidget")
        return .result()
    }
}

@available(iOS 16, *)
extension MealPartTime: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Meal Part Time"

    static var caseDisplayRepresentations: [MealPartTime: DisplayRepresentation] = [
        .breakfast: "아침",
        .lunch: "점심",
        .dinner: "저녁"
    ]
}
