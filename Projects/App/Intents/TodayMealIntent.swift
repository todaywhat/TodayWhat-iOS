import AppIntents
import DateUtil
import Entity
import EnumUtil
import Foundation
import FoundationUtil
import NeisClient

@available(iOS 16.0, *)
struct TodayMealIntent: AppIntent {
    static var title: LocalizedStringResource = "오늘 급식 확인"
    static var description = IntentDescription("설정된 학교의 급식 정보를 Siri로 확인합니다.")

    @Parameter(title: "급식 시간대")
    var mealPartTime: MealPartTime?

    func perform() async throws -> some IntentResult {
        let service = SiriMealService()
        do {
            let result = try await service.fetchMeal(
                requestedMealTime: mealPartTime,
                at: Date()
            )
            let dialog = service.makeDialog(for: result)
            return .result(dialog: IntentDialog(dialog))
        } catch {
            let message = service.makeErrorMessage(from: error)
            return .result(dialog: IntentDialog(message))
        }
    }
}

@available(iOS 16.0, *)
struct TodayWhatShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: TodayMealIntent(),
                phrases: [
                    "오늘 급식 뭐야 in \(.applicationName)",
                    "오늘 급식 알려줘 in \(.applicationName)"
                ],
                shortTitle: "오늘 급식",
                systemImageName: "fork.knife"
            )
        ]
    }
}

struct SiriMealService {
    struct Result {
        let meal: Meal
        let date: Date
        let mealTime: MealPartTime
        let isAutomatic: Bool
    }

    func fetchMeal(requestedMealTime: MealPartTime?, at now: Date) async throws -> Result {
        let settings = try MealSettings.load()
        let resolvedRequest = requestedMealTime ?? MealPartTime(hour: now)
        let (meal, displayDate) = try await fetchMealAndDate(
            requestedMealTime: resolvedRequest,
            currentDate: now,
            settings: settings
        )
        let finalMealTime: MealPartTime

        if requestedMealTime == nil {
            finalMealTime = determineDisplayedMealTime(
                requestedMealTime: resolvedRequest,
                meal: meal,
                displayDate: displayDate,
                now: now
            ) ?? MealPartTime(hour: displayDate)
        } else {
            finalMealTime = resolvedRequest
        }

        return Result(
            meal: meal,
            date: displayDate,
            mealTime: finalMealTime,
            isAutomatic: requestedMealTime == nil
        )
    }

    func makeDialog(for result: Result) -> String {
        let isToday = Calendar.current.isDateInToday(result.date)
        let mealType = mealType(from: result.mealTime)
        let subMeal = result.meal.mealByType(type: mealType)

        guard !subMeal.meals.isEmpty else {
            if isToday {
                return "오늘은 \(result.mealTime.display) 급식 정보가 없어요."
            } else {
                return "\(formattedDate(result.date))에는 \(result.mealTime.display) 급식 정보가 없어요."
            }
        }

        let menu = subMeal.meals.joined(separator: ", ")
        if isToday {
            return "오늘 \(result.mealTime.display) 급식은 \(menu)입니다."
        } else {
            return "\(formattedDate(result.date)) \(result.mealTime.display) 급식은 \(menu)입니다."
        }
    }

    func makeErrorMessage(from error: Error) -> String {
        if let mealError = error as? MealServiceError,
           let description = mealError.errorDescription {
            return description
        }
        return "급식 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요."
    }
}

private extension SiriMealService {
    func fetchMealAndDate(
        requestedMealTime: MealPartTime,
        currentDate: Date,
        settings: MealSettings
    ) async throws -> (Meal, Date) {
        var targetDate = currentDate

        if currentDate.hour >= 20 {
            targetDate = targetDate.adding(by: .day, value: 1)
            let meal = try await fetchMeal(on: targetDate, settings: settings)
            return (meal, adjustForWeekend(targetDate, skipWeekend: settings.isSkipWeekend))
        }

        let todayMeal = try await fetchMeal(on: targetDate, settings: settings)
        if isMealEmpty(todayMeal, for: requestedMealTime) {
            let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]
            if let startIndex = mealTimes.firstIndex(of: requestedMealTime) {
                for index in startIndex..<mealTimes.count where !isMealEmpty(todayMeal, for: mealTimes[index]) {
                    return (todayMeal, adjustForWeekend(targetDate, skipWeekend: settings.isSkipWeekend))
                }
            }

            let nextDate = targetDate.adding(by: .day, value: 1)
            let nextMeal = try await fetchMeal(on: nextDate, settings: settings)
            for mealTime in [.breakfast, .lunch, .dinner] where !isMealEmpty(nextMeal, for: mealTime) {
                return (nextMeal, adjustForWeekend(nextDate, skipWeekend: settings.isSkipWeekend))
            }

            return (todayMeal, adjustForWeekend(targetDate, skipWeekend: settings.isSkipWeekend))
        } else {
            return (todayMeal, adjustForWeekend(targetDate, skipWeekend: settings.isSkipWeekend))
        }
    }

    func fetchMeal(on date: Date, settings: MealSettings) async throws -> Meal {
        var requestDate = date
        if settings.isSkipWeekend {
            if requestDate.weekday == 7 {
                requestDate = requestDate.adding(by: .day, value: 2)
            } else if requestDate.weekday == 1 {
                requestDate = requestDate.adding(by: .day, value: 1)
            }
        }

        let month = requestDate.month < 10 ? "0\(requestDate.month)" : "\(requestDate.month)"
        let day = requestDate.day < 10 ? "0\(requestDate.day)" : "\(requestDate.day)"
        let reqDate = "\(requestDate.year)\(month)\(day)"

        let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
        let queryItems: [URLQueryItem] = [
            .init(name: "KEY", value: key),
            .init(name: "Type", value: "json"),
            .init(name: "pIndex", value: "1"),
            .init(name: "pSize", value: "10"),
            .init(name: "ATPT_OFCDC_SC_CODE", value: settings.orgCode),
            .init(name: "SD_SCHUL_CODE", value: settings.schoolCode),
            .init(name: "MLSV_FROM_YMD", value: reqDate),
            .init(name: "MLSV_TO_YMD", value: reqDate)
        ]

        let response: [MealResponse]
        do {
            response = try await NeisClient().fetchDataOnNeis(
                "mealServiceDietInfo",
                queryItem: queryItems,
                key: "mealServiceDietInfo",
                type: [MealResponse].self
            )
        } catch {
            throw MealServiceError.network
        }

        let breakfast = parseMeal(in: response, type: .breakfast)
        let lunch = parseMeal(in: response, type: .lunch)
        let dinner = parseMeal(in: response, type: .dinner)

        return Meal(breakfast: breakfast, lunch: lunch, dinner: dinner)
    }

    func parseMeal(in response: [MealResponse], type: MealType) -> Meal.SubMeal {
        response.first { $0.type == type }
            .map { dto in
                Meal.SubMeal(
                    meals: dto.info.replacingOccurrences(of: " ", with: "").components(separatedBy: "<br/>"),
                    cal: Double(dto.calInfo.components(separatedBy: " ").first ?? "0") ?? 0
                )
            } ?? Meal.SubMeal(meals: [], cal: 0)
    }

    func adjustForWeekend(_ date: Date, skipWeekend: Bool) -> Date {
        guard skipWeekend else { return date }
        if date.weekday == 7 {
            return date.adding(by: .day, value: 2)
        }
        if date.weekday == 1 {
            return date.adding(by: .day, value: 1)
        }
        return date
    }

    func determineDisplayedMealTime(
        requestedMealTime: MealPartTime,
        meal: Meal,
        displayDate: Date,
        now: Date
    ) -> MealPartTime? {
        let mealTimes: [MealPartTime] = [.breakfast, .lunch, .dinner]

        if Calendar.current.isDate(displayDate, inSameDayAs: now) {
            if !isMealEmpty(meal, for: requestedMealTime) {
                return requestedMealTime
            }

            if let futureMeal = mealTimes
                .filter({ $0.rawValue >= requestedMealTime.rawValue })
                .first(where: { !isMealEmpty(meal, for: $0) }) {
                return futureMeal
            }
        }

        return mealTimes.first(where: { !isMealEmpty(meal, for: $0) })
    }

    func isMealEmpty(_ meal: Meal, for mealTime: MealPartTime) -> Bool {
        switch mealTime {
        case .breakfast: return meal.breakfast.meals.isEmpty
        case .lunch: return meal.lunch.meals.isEmpty
        case .dinner: return meal.dinner.meals.isEmpty
        }
    }

    func formattedDate(_ date: Date) -> String {
        "\(date.month)월 \(date.day)일 \(date.weekdayString)"
    }

    func mealType(from partTime: MealPartTime) -> MealType {
        switch partTime {
        case .breakfast: return .breakfast
        case .lunch: return .lunch
        case .dinner: return .dinner
        }
    }
}

private struct MealSettings {
    let orgCode: String
    let schoolCode: String
    let isSkipWeekend: Bool

    static func load() throws -> MealSettings {
        let defaults = UserDefaults.app
        guard
            let orgCode = defaults.string(forKey: UserDefaultsKeys.orgCode.rawValue),
            let schoolCode = defaults.string(forKey: UserDefaultsKeys.schoolCode.rawValue)
        else {
            throw MealServiceError.missingSchool
        }

        let isSkipWeekend = defaults.bool(forKey: UserDefaultsKeys.isSkipWeekend.rawValue)

        return MealSettings(
            orgCode: orgCode,
            schoolCode: schoolCode,
            isSkipWeekend: isSkipWeekend
        )
    }
}

private enum MealServiceError: LocalizedError {
    case missingSchool
    case network

    var errorDescription: String? {
        switch self {
        case .missingSchool:
            return "학교 정보를 찾을 수 없어요. 앱에서 학교를 먼저 설정해주세요."
        case .network:
            return "급식 정보를 불러오는 중 오류가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
}

private struct MealResponse: Decodable {
    let info: String
    let type: MealType
    let calInfo: String

    enum CodingKeys: String, CodingKey {
        case info = "DDISH_NM"
        case type = "MMEAL_SC_NM"
        case calInfo = "CAL_INFO"
    }
}
