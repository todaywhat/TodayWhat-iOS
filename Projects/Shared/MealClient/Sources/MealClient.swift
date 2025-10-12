import DateUtil
import Dependencies
import Entity
import EnumUtil
import Foundation
import NeisClient
import UserDefaultsClient

public struct MealClient: Sendable {
    public var fetchMeal: @Sendable (_ date: Date) async throws -> Meal
    public var fetchMeals: @Sendable (_ startDate: Date, _ dayCount: Int) async throws -> [Date: Meal]
}

extension MealClient: DependencyKey {
    public static var liveValue: MealClient = MealClient(
        fetchMeal: { date in
            var date = date
            @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient

            if userDefaultsClient.getValue(.isSkipWeekend) as? Bool == true {
                if date.weekday == 7 {
                    date = date.adding(by: .day, value: 2)
                } else if date.weekday == 1 {
                    date = date.adding(by: .day, value: 1)
                }
            }

            guard
                let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
                let code = userDefaultsClient.getValue(.schoolCode) as? String
            else {
                return Meal.empty
            }

            @Dependency(\.neisClient) var neisClient

            let month = date.month < 10 ? "0\(date.month)" : "\(date.month)"
            let day = date.day < 10 ? "0\(date.day)" : "\(date.day)"
            let reqDate = "\(date.year)\(month)\(day)"

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
        },
        fetchMeals: { startDate, dayCount in
            guard dayCount > 0 else { return [:] }
            @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient
            let calendar = Calendar.current
            let normalizedStart = calendar.startOfDay(for: startDate)

            guard
                let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
                let code = userDefaultsClient.getValue(.schoolCode) as? String
            else {
                return populateEmptyMeals(calendar: calendar, start: normalizedStart, dayCount: dayCount)
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.locale = Locale(identifier: "ko_kr")

            let endDate = calendar.date(byAdding: .day, value: dayCount - 1, to: normalizedStart) ?? normalizedStart

            @Dependency(\.neisClient) var neisClient
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
                        .init(name: "MLSV_FROM_YMD", value: formatter.string(from: normalizedStart)),
                        .init(name: "MLSV_TO_YMD", value: formatter.string(from: endDate))
                    ],
                    key: "mealServiceDietInfo",
                    type: [SingleMealResponseDTO].self
                )
            } catch {
                response = []
            }

            let groupedByDate = Dictionary(grouping: response, by: \.serviceDate)
            var result = populateEmptyMeals(calendar: calendar, start: normalizedStart, dayCount: dayCount)

            for (dateString, entries) in groupedByDate {
                guard let date = formatter.date(from: dateString) else { continue }
                let normalizedDate = calendar.startOfDay(for: date)

                let breakfast = parseMeal(response: entries, type: .breakfast)
                let lunch = parseMeal(response: entries, type: .lunch)
                let dinner = parseMeal(response: entries, type: .dinner)

                result[normalizedDate] = Meal(
                    breakfast: breakfast,
                    lunch: lunch,
                    dinner: dinner
                )
            }

            return result
        }
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
