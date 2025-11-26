import DateUtil
import Dependencies
import Entity
import EnumUtil
import Foundation
import LocalDatabaseClient
import NeisClient
import UserDefaultsClient

public struct MealClient: Sendable {
    public var fetchMeal: @Sendable (_ date: Date) async throws -> Meal
    public var fetchMeals: @Sendable (_ startDate: Date, _ dayCount: Int) async throws -> [Date: Meal]
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    formatter.locale = Locale(identifier: "ko_kr")
    return formatter.string(from: date)
}

extension MealClient: DependencyKey {
    public static var liveValue: MealClient = MealClient(
        fetchMeal: { date in
            var date = date
            @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient
            @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient

            if userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true {
                if date.weekday == 7 {
                    date = date.adding(by: .day, value: 2)
                } else if date.weekday == 1 {
                    date = date.adding(by: .day, value: 1)
                }
            }

            let reqDate = formatDate(date)

            if let cachedEntity = try? localDatabaseClient.readRecordByColumn(
                record: MealLocalEntity.self,
                column: "date",
                value: reqDate
            ) {
                let cachedMeal = cachedEntity.toMeal()

                if !cachedMeal.isEmpty {
                    Task.detached {
                        await syncMealFromServer(date: date, reqDate: reqDate)
                    }
                    return cachedMeal
                }
            }

            let meal = await fetchMealFromServer(date: date, reqDate: reqDate)

            let entity = MealLocalEntity(date: reqDate, meal: meal)
            try? localDatabaseClient.save(record: entity)

            return meal
        },
        fetchMeals: { startDate, dayCount in
            guard dayCount > 0 else { return [:] }
            @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient
            @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient
            let calendar = Calendar.autoupdatingCurrent
            let normalizedStart = calendar.startOfDay(for: startDate)

            guard
                let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
                let code = userDefaultsClient.getValue(.schoolCode) as? String
            else {
                return populateEmptyMeals(calendar: calendar, start: normalizedStart, dayCount: dayCount)
            }

            var dateStrings: [String] = []
            var dateMapping: [String: Date] = [:]
            for offset in 0..<dayCount {
                guard let date = calendar.date(byAdding: .day, value: offset, to: normalizedStart) else { continue }
                let normalizedDate = calendar.startOfDay(for: date)
                let dateString = formatDate(normalizedDate)
                dateStrings.append(dateString)
                dateMapping[dateString] = normalizedDate
            }

            var result: [Date: Meal] = [:]
            if let cachedEntities = try? localDatabaseClient.readRecordsByColumn(
                record: MealLocalEntity.self,
                column: "date",
                values: dateStrings
            ) {
                for entity in cachedEntities {
                    if let date = dateMapping[entity.date] {
                        result[date] = entity.toMeal()
                    }
                }
            }

            let hasNonEmptyCache = !result.isEmpty && result.values.allSatisfy { !$0.isEmpty }

            if hasNonEmptyCache {
                Task.detached {
                    await syncMealsFromServer(
                        startDate: normalizedStart,
                        dayCount: dayCount,
                        orgCode: orgCode,
                        code: code
                    )
                }

                for (dateString, date) in dateMapping where result[date] == nil {
                    result[date] = Meal.empty
                }

                return result
            }

            let meals = await fetchMealsFromServer(
                startDate: normalizedStart,
                dayCount: dayCount,
                orgCode: orgCode,
                code: code
            )

            return meals
        }
    )
}

private func fetchMealFromServer(date: Date, reqDate: String) async -> Meal {
    @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient
    @Dependency(\.neisClient) var neisClient

    guard
        let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
        let code = userDefaultsClient.getValue(.schoolCode) as? String
    else {
        return Meal.empty
    }

    let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    let response: [SingleMealResponseDTO]
    do {
        response = try await neisClient.fetchDataOnNeis(
            "mealServiceDietInfo",
            queryItem: [
                .init(name: "KEY", value: key),
                .init(name: "Type", value: "json"),
                .init(name: "pIndex", value: "1"),
                .init(name: "pSize", value: "10"),
                .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                .init(name: "SD_SCHUL_CODE", value: code),
                .init(name: "MLSV_FROM_YMD", value: reqDate),
                .init(name: "MLSV_TO_YMD", value: reqDate)
            ],
            key: "mealServiceDietInfo",
            type: [SingleMealResponseDTO].self
        )
    } catch {
        response = []
    }

    let breakfast = parseMeal(response: response, type: .breakfast)
    let lunch = parseMeal(response: response, type: .lunch)
    let dinner = parseMeal(response: response, type: .dinner)

    return Meal(breakfast: breakfast, lunch: lunch, dinner: dinner)
}

private func syncMealFromServer(date: Date, reqDate: String) async {
    @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient

    let meal = await fetchMealFromServer(date: date, reqDate: reqDate)
    let entity = MealLocalEntity(date: reqDate, meal: meal)

    try? localDatabaseClient.delete(record: MealLocalEntity.self, key: entity.id)
    try? localDatabaseClient.save(record: entity)
}

private func fetchMealsFromServer(
    startDate: Date,
    dayCount: Int,
    orgCode: String,
    code: String
) async -> [Date: Meal] {
    @Dependency(\.neisClient) var neisClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient: LocalDatabaseClient

    let calendar = Calendar.autoupdatingCurrent
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    formatter.locale = Locale(identifier: "ko_kr")

    let endDate = calendar.date(byAdding: .day, value: dayCount - 1, to: startDate) ?? startDate

    let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    let response: [SingleMealResponseDTO]
    do {
        response = try await neisClient.fetchDataOnNeis(
            "mealServiceDietInfo",
            queryItem: [
                .init(name: "KEY", value: key),
                .init(name: "Type", value: "json"),
                .init(name: "pIndex", value: "1"),
                .init(name: "pSize", value: "100"),
                .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                .init(name: "SD_SCHUL_CODE", value: code),
                .init(name: "MLSV_FROM_YMD", value: formatter.string(from: startDate)),
                .init(name: "MLSV_TO_YMD", value: formatter.string(from: endDate))
            ],
            key: "mealServiceDietInfo",
            type: [SingleMealResponseDTO].self
        )
    } catch {
        response = []
    }

    let groupedByDate = Dictionary(grouping: response, by: \.serviceDate)

    var result: [Date: Meal] = [:]

    for (dateString, entries) in groupedByDate {
        let breakfast = parseMeal(response: entries, type: .breakfast)
        let lunch = parseMeal(response: entries, type: .lunch)
        let dinner = parseMeal(response: entries, type: .dinner)

        let meal = Meal(
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner
        )

        let entity = MealLocalEntity(date: dateString, meal: meal)

        if let existing = try? localDatabaseClient.readRecordByColumn(
            record: MealLocalEntity.self,
            column: "date",
            value: dateString
        ) {
            try? localDatabaseClient.delete(record: existing)
        }
        try? localDatabaseClient.save(record: entity)

        if let date = formatter.date(from: dateString) {
            let normalizedDate = calendar.startOfDay(for: date)
            result[normalizedDate] = meal
        }
    }

    var currentDate = calendar.startOfDay(for: startDate)
    for _ in 0..<dayCount {
        if result[currentDate] == nil {
            result[currentDate] = Meal.empty
        }
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
        currentDate = nextDate
    }

    return result
}

private func syncMealsFromServer(
    startDate: Date,
    dayCount: Int,
    orgCode: String,
    code: String
) async {
    _ = await fetchMealsFromServer(
        startDate: startDate,
        dayCount: dayCount,
        orgCode: orgCode,
        code: code
    )
}

private func parseMeal(response: [SingleMealResponseDTO], type: MealType) -> Meal.SubMeal {
    return response.first { $0.type == type }
        .map { dto in
            Meal.SubMeal(
                meals: dto.info
                    .replacingOccurrences(of: " ", with: "")
                    .components(separatedBy: "<br/>"),
                cal: Double(dto.calInfo.components(separatedBy: " ").first ?? "0") ?? 0
            )
        } ?? .init(meals: [], cal: 0)
}

private func populateEmptyMeals(calendar: Calendar, start: Date, dayCount: Int) -> [Date: Meal] {
    var result: [Date: Meal] = [:]
    for offset in 0..<dayCount {
        guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { continue }
        let normalizedDate = calendar.startOfDay(for: date)
        result[normalizedDate] = Meal.empty
    }
    return result
}

private extension Meal {
    static var empty: Meal {
        Meal(
            breakfast: .init(meals: [], cal: 0),
            lunch: .init(meals: [], cal: 0),
            dinner: .init(meals: [], cal: 0)
        )
    }
}

public extension DependencyValues {
    var mealClient: MealClient {
        get { self[MealClient.self] }
        set { self[MealClient.self] = newValue }
    }
}
