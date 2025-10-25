import Dependencies
import Entity
import EnumUtil
import Intents
import LocalDatabaseClient
import MealClient
import SwiftUI
import TimeTableClient
import UserDefaultsClient
import WidgetKit

struct MealTimeTableProvider: IntentTimelineProvider {
    typealias Entry = MealTimeTableEntry
    typealias Intent = DisplayMealIntent

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    func placeholder(in context: Context) -> MealTimeTableEntry {
        return MealTimeTableEntry.empty()
    }

    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (MealTimeTableEntry) -> Void
    ) {
        Task {
            do {
                let currentDate = Date()
                async let (meal, mealDisplayDate, mealPart) = fetchMealEntry(
                    for: configuration,
                    currentDate: currentDate
                )
                async let (timetables, timetableDisplayDate) = fetchTimeTables(date: currentDate)
                let allergies = fetchAllergies()

                let entry = try await MealTimeTableEntry(
                    date: currentDate,
                    timeTableDate: transformSkippingDate(timetableDisplayDate),
                    timetables: timetables,
                    mealDate: transformSkippingDate(mealDisplayDate),
                    meal: meal,
                    mealPartTime: mealPart,
                    allergyList: allergies
                )
                completion(entry)
            } catch {
                let entry = MealTimeTableEntry.empty()
                completion(entry)
            }
        }
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? .init()

        Task {
            do {
                let currentDate = Date()
                async let (meal, mealDisplayDate, mealPart) = fetchMealEntry(
                    for: configuration,
                    currentDate: currentDate
                )
                async let (timetables, timetableDisplayDate) = fetchTimeTables(date: currentDate)
                let allergies = fetchAllergies()

                let entry = try await MealTimeTableEntry(
                    date: currentDate,
                    timeTableDate: transformSkippingDate(timetableDisplayDate),
                    timetables: timetables,
                    mealDate: transformSkippingDate(mealDisplayDate),
                    meal: meal,
                    mealPartTime: mealPart,
                    allergyList: allergies
                )
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                let entry = MealTimeTableEntry.empty()
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }

    private func fetchAllergies() -> [AllergyType] {
        let allergies = try? localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
            .compactMap { AllergyType(rawValue: $0.allergy) }
        return allergies ?? []
    }

    private func fetchMealEntry(
        for configuration: Intent,
        currentDate: Date
    ) async throws -> (Meal, Date, MealPartTime) {
        let requestedMealTime: MealPartTime = if configuration.displayMeal == .auto {
            MealPartTime(hour: currentDate)
        } else {
            configuration.displayMeal.toMealPartTime()
        }

        let (meal, displayDate) = try await fetchMealAndDate(for: requestedMealTime, currentDate: currentDate)

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

        return (meal, displayDate, displayMealTime)
    }

    private func fetchTimeTables(date: Date) async throws -> ([TimeTable], Date) {
        var date = date
        if date.hour >= 20 {
            date = date.adding(by: .day, value: 1)
        }

        let isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
        if isOnModifiedTimeTable {
            let modifiedTimeTables: [ModifiedTimeTableLocalEntity]? = try? localDatabaseClient
                .readRecords(as: ModifiedTimeTableLocalEntity.self)
                .filter { $0.weekday == WeekdayType(weekday: date.weekday).rawValue }
            let timeTables = (modifiedTimeTables ?? [])
                .sorted { $0.perio < $1.perio }
                .map { TimeTable(perio: $0.perio, content: $0.content) }

            if timeTables.isEmpty {
                let timeTable = try await timeTableClient.fetchTimeTable(date).prefix(7)
                return (Array(timeTable), date)
            }
            return (timeTables, date)
        }

        let timeTable = try await timeTableClient.fetchTimeTable(date).prefix(7)
        return (Array(timeTable), date)
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
                    return (meal, transformSkippingDate(targetDate))
                }

                // 2. 현재 날짜에 비어있지 않은 급식이 없다면 다음 날 확인 후 return
                let nextDate = targetDate.adding(by: .day, value: 1)
                let nextDayMeal = try await mealClient.fetchMeal(nextDate)

                // 3. 다음 날 아침부터 순서대로 확인 후 return
                let nextMealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]
                for mealTime in nextMealTimes where !isMealEmpty(nextDayMeal, for: mealTime) {
                    return (nextDayMeal, transformSkippingDate(nextDate))
                }

                return (meal, transformSkippingDate(targetDate))
            } else {
                return (meal, transformSkippingDate(targetDate))
            }
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

struct MealTimeTableEntry: TimelineEntry {
    let date: Date
    let timeTableDate: Date
    let timetables: [TimeTable]
    let mealDate: Date
    let meal: Meal
    let mealPartTime: MealPartTime
    let allergyList: [AllergyType]

    static func empty() -> MealTimeTableEntry {
        let currentDate = Date()
        return MealTimeTableEntry(
            date: currentDate,
            timeTableDate: currentDate,
            timetables: [],
            mealDate: currentDate,
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

struct TodayWhatMealTimeTableWidget: Widget {
    let kind: String = "TodayWhatMealTimeTableWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: DisplayMealIntent.self,
            provider: MealTimeTableProvider()
        ) { entry in
            MealTimeTableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 급식이랑 시간표 뭐임")
        .description("시간에 따라 시간표와 아침, 점심, 저녁 급식을 확인해요!\n(아침0~8, 점심8~13, 저녁13~20, 내일아침20~24)")
        .contentMarginsDisabled()
        .supportedFamilies([.systemMedium])
    }
}
