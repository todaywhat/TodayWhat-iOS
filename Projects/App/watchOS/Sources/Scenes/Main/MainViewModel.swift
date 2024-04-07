import Combine
import Dependencies
import Entity
import EnumUtil
import Foundation
import LocalDatabaseClient
import MealClient
import TimeTableClient
import UserDefaultsClient

final class MainViewModel: ObservableObject {
    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Published var part: DisplayInfoPart = .breakfast
    @Published var timeTables: [TimeTable] = []
    var meal: Meal?
    var currentMeal: [String] {
        switch part {
        case .breakfast:
            return meal?.breakfast.meals ?? []

        case .lunch:
            return meal?.lunch.meals ?? []

        case .dinner:
            return meal?.dinner.meals ?? []

        default:
            return []
        }
    }

    @MainActor
    func onAppear() async {
        do {
            let todayDate = Date()
            let meal = try await mealClient.fetchMeal(todayDate)
            self.meal = meal

            let isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
            if isOnModifiedTimeTable {
                let modifiedTimeTables = try localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
                    .filter { $0.weekday == WeekdayType(weekday: todayDate.weekday).rawValue }
                self.timeTables = modifiedTimeTables
                    .sorted { $0.perio < $1.perio }
                    .map { TimeTable(perio: $0.perio, content: $0.content) }
            } else {
                let timeTable = try await timeTableClient.fetchTimeTable(Date())
                self.timeTables = timeTable
            }
        } catch {}
    }
}
