import Combine
import Entity
import Dependencies
import MealClient
import TimeTableClient
import EnumUtil
import Foundation

final class MainViewModel: ObservableObject {
    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient
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
            let meal = try await mealClient.fetchMeal(Date())
            self.meal = meal
            let timeTable = try await timeTableClient.fetchTimeTable(Date())
            self.timeTables = timeTable
        } catch {
            
        }
    }
}
