import Dependencies
import Entity
import EnumUtil
import IntentsUI
import LocalDatabaseClient
import MealClient
import SwiftUI
import TimeTableClient
import WidgetKit

struct MealProvider: IntentTimelineProvider {
    typealias Entry = MealEntry
    typealias Intent = DisplayMealIntent

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

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
            return (meal, targetDate)
        } else {
            let meal = try await mealClient.fetchMeal(targetDate)

            if isMealEmpty(meal, for: requestedMealTime) {
                // 1. 요청한 MealTime 이후의 시간도 확인 후 return
                let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]
                let startIndex = mealTimes.firstIndex(of: requestedMealTime) ?? 0

                for i in startIndex..<mealTimes.count where !isMealEmpty(meal, for: mealTimes[i]) {
                    return (meal, targetDate)
                }
            }

            // 2. 현재 날짜에 비어있지 않은 급식이 없다면 다음 날 확인 후 return
            let nextDate = targetDate.adding(by: .day, value: 1)
            let nextDayMeal = try await mealClient.fetchMeal(nextDate)

            // 3. 다음 날 아침부터 순서대로 확인 후 return
            let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]
            for mealTime in mealTimes where !isMealEmpty(nextDayMeal, for: mealTime) {
                return (nextDayMeal, nextDate)
            }

            return (nextDayMeal, nextDate)
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
}

struct TimeTableProvider: TimelineProvider {
    typealias Entry = TimeTableEntry

    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    func placeholder(in context: Context) -> TimeTableEntry {
        .empty()
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (TimeTableEntry) -> Void
    ) {
        Task {
            var currentDate = Date()
            if currentDate.hour >= 20 {
                currentDate = currentDate.adding(by: .day, value: 1)
            }
            do {
                let timeTable = try await timeTableClient.fetchTimeTable(currentDate).prefix(7)
                let entry = TimeTableEntry(date: currentDate, timeTable: Array(timeTable))
                completion(entry)
            } catch {
                let entry = TimeTableEntry.empty()
                completion(entry)
            }
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<TimeTableEntry>) -> Void
    ) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? .init()
        Task {
            var currentDate = Date()
            if currentDate.hour >= 20 {
                currentDate = currentDate.adding(by: .hour, value: 5)
            }
            do {
                let timeTable = try await fetchTimeTables(date: currentDate)
                let entry = TimeTableEntry(date: currentDate, timeTable: Array(timeTable))
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                let entry = TimeTableEntry.empty()
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }

    private func fetchTimeTables(date: Date) async throws -> [TimeTable] {
        let isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
        if isOnModifiedTimeTable {
            let modifiedTimeTables: [ModifiedTimeTableLocalEntity]? = try? localDatabaseClient
                .readRecords(as: ModifiedTimeTableLocalEntity.self)
                .filter { $0.weekday == WeekdayType(weekday: date.weekday).rawValue }
            return (modifiedTimeTables ?? [])
                .sorted { $0.perio < $1.perio }
                .map { TimeTable(perio: $0.perio, content: $0.content) }
        }
        let timeTable = try await timeTableClient.fetchTimeTable(date).prefix(7)
        return Array(timeTable)
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

struct TimeTableEntry: TimelineEntry {
    let date: Date
    let timeTable: [TimeTable]

    static func empty() -> TimeTableEntry {
        TimeTableEntry(
            date: Date(),
            timeTable: []
        )
    }
}

@main
struct TodayWhatWidget: WidgetBundle {
    var body: some Widget {
        TodayWhatMealWidget()
        TodayWhatTimeTableWidget()
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

struct TodayWhatTimeTableWidget: Widget {
    let kind: String = "TodayWhatTimeTableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TimeTableProvider()
        ) { entry in
            TimeTableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 시간표 뭐임")
        .description("오늘 시간표를 확인해요!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
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

struct TodayWhatWidget_Previews: PreviewProvider {
    static var previews: some View {
        MealWidgetEntryView(
            entry: .empty()
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
