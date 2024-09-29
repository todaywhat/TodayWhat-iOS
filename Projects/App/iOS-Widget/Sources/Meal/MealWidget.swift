import Dependencies
import Entity
import EnumUtil
import Intents
import LocalDatabaseClient
import MealClient
import SwiftUI
import UserDefaultsClient
import WidgetKit

struct MealProvider: IntentTimelineProvider {
    typealias Entry = MealEntry
    typealias Intent = DisplayMealIntent

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    func placeholder(in context: Context) -> MealEntry {
        return MealEntry.empty()
    }

    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (MealEntry) -> Void
    ) {
        Task {
            let entry = await fetchMealEntry(for: configuration)
            completion(entry)
        }
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? .init()
        Task {
            let entry = await fetchMealEntry(for: configuration)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchMealEntry(for configuration: Intent) async -> MealEntry {
        let currentDate = Date()
        let requestedMealTime: MealPartTime = if configuration.displayMeal == .auto {
            MealPartTime(hour: currentDate)
        } else {
            configuration.displayMeal.toMealPartTime()
        }

        do {
            let (meal, displayDate) = try await fetchMealAndDate(for: requestedMealTime, currentDate: currentDate)
            let allergies = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                .compactMap { AllergyType(rawValue: $0.allergy) }

            let displayMealTime: MealPartTime

            if currentDate.compare(displayDate) == .orderedSame, configuration.displayMeal == .auto {
                displayMealTime = determineDisplayedMealTime(
                    requestedMealTime: requestedMealTime,
                    meal: meal,
                    currentDate: displayDate
                ) ?? MealPartTime(hour: displayDate)
            } else if currentDate.compare(displayDate) != .orderedSame, configuration.displayMeal == .auto {
                displayMealTime = determineDisplayedMealTime(
                    meal: meal,
                    currentDate: displayDate
                ) ?? MealPartTime(hour: displayDate)
            } else {
                displayMealTime = configuration.displayMeal.toMealPartTime()
            }

            return MealEntry(
                date: displayDate,
                meal: meal,
                mealPartTime: displayMealTime,
                allergyList: allergies
            )
        } catch {
            return MealEntry.empty()
        }
    }

    private func fetchMealAndDate(
        for requestedMealTime: MealPartTime,
        currentDate: Date
    ) async throws -> (Meal, Date) {
        var targetDate = currentDate
        if currentDate.hour >= 20 {
            targetDate = targetDate.adding(by: .day, value: 1)

            let meal = try await mealClient.fetchMeal(targetDate)
            return (meal, transformSkippingDate(targetDate))
        } else {
            let meal = try await mealClient.fetchMeal(targetDate)

            if isMealEmpty(meal, for: requestedMealTime) {
                // 1. 요청한 MealTime 이후의 시간도 확인 후 return
                let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]
                let startIndex = mealTimes.firstIndex(of: requestedMealTime) ?? 0

                for i in startIndex..<mealTimes.count where !isMealEmpty(meal, for: mealTimes[i]) {
                    return (meal, transformSkippingDate(targetDate))
                }
            }

            // 2. 현재 날짜에 비어있지 않은 급식이 없다면 다음 날 확인 후 return
            let nextDate = targetDate.adding(by: .day, value: 1)
            let nextDayMeal = try await mealClient.fetchMeal(nextDate)

            // 3. 다음 날 아침부터 순서대로 확인 후 return
            let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]
            for mealTime in mealTimes where !isMealEmpty(nextDayMeal, for: mealTime) {
                return (nextDayMeal, transformSkippingDate(nextDate))
            }

            return (nextDayMeal, transformSkippingDate(nextDate))
        }
    }

    private func determineDisplayedMealTime(
        requestedMealTime: MealPartTime,
        meal: Meal,
        currentDate: Date
    ) -> MealPartTime? {
        let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]

        let availableMeals = mealTimes.filter { !isMealEmpty(meal, for: $0) }

        if availableMeals.contains(requestedMealTime) {
            return requestedMealTime
        }

        let futureAvailableMeals = availableMeals.filter { $0.rawValue >= requestedMealTime.rawValue }
        if let nextAvailableMeal = futureAvailableMeals.first {
            return nextAvailableMeal
        }

        return nil
    }

    private func determineDisplayedMealTime(
        meal: Meal,
        currentDate: Date
    ) -> MealPartTime? {
        let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]

        let availableMeals = mealTimes.filter { !isMealEmpty(meal, for: $0) }

        if let nextAvailableMeal = availableMeals.first {
            return nextAvailableMeal
        }

        return nil
    }

    private func isMealEmpty(_ meal: Meal, for mealTime: MealPartTime) -> Bool {
        switch mealTime {
        case .breakfast: return meal.breakfast.meals.isEmpty
        case .lunch: return meal.lunch.meals.isEmpty
        case .dinner: return meal.dinner.meals.isEmpty
        }
    }

    private func transformSkippingDate(_ date: Date) -> Date {
        var resultDate = date

        if userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true {
            if resultDate.weekday == 7 {
                resultDate = resultDate.adding(by: .day, value: 2)
            } else if resultDate.weekday == 1 {
                resultDate = resultDate.adding(by: .day, value: 1)
            }
        }

        return resultDate
    }
}

private extension DisplayMeal {
    func toMealPartTime() -> MealPartTime {
        switch self {
        case .breakfast:
            return .breakfast

        case .lunch:
            return .lunch

        case .dinner:
            return .dinner

        default:
            return .breakfast
        }
    }
}

struct MealEntry: TimelineEntry {
    let date: Date
    let meal: Meal
    let mealPartTime: MealPartTime
    let allergyList: [AllergyType]

    static func empty() -> MealEntry {
        MealEntry(
            date: Date(),
            meal: .init(
                breakfast: .init(meals: [], cal: 0),
                lunch: .init(meals: [], cal: 0),
                dinner: .init(meals: [], cal: 0)
            ),
            mealPartTime: .breakfast,
            allergyList: []
        )
    }
}

struct TodayWhatMealWidget: Widget {
    let kind: String = "TodayWhatMealWidget"

    var body: some WidgetConfiguration {
        let widgetFamily: [WidgetFamily] = if #available(iOSApplicationExtension 16.0, *) {
            [.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular]
        } else {
            [.systemSmall, .systemMedium, .systemLarge]
        }

        return IntentConfiguration(
            kind: kind,
            intent: DisplayMealIntent.self,
            provider: MealProvider()
        ) { entry in
            MealWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 급식 뭐임")
        .description("시간에 따라 아침, 점심, 저녁 급식을 확인해요!\n(아침0~8, 점심8~13, 저녁13~20, 내일아침20~24)")
        .contentMarginsDisabled()
        .supportedFamilies(widgetFamily)
    }
}
