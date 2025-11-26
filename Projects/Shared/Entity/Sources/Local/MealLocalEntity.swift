import Foundation
import GRDB

public struct MealLocalEntity: Codable, FetchableRecord, PersistableRecord {
    public let id: String
    public let date: String // yyyyMMdd format
    public let breakfastMeals: String // JSON array
    public let breakfastCal: Double
    public let lunchMeals: String // JSON array
    public let lunchCal: Double
    public let dinnerMeals: String // JSON array
    public let dinnerCal: Double
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        date: String,
        breakfastMeals: String,
        breakfastCal: Double,
        lunchMeals: String,
        lunchCal: Double,
        dinnerMeals: String,
        dinnerCal: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.breakfastMeals = breakfastMeals
        self.breakfastCal = breakfastCal
        self.lunchMeals = lunchMeals
        self.lunchCal = lunchCal
        self.dinnerMeals = dinnerMeals
        self.dinnerCal = dinnerCal
        self.createdAt = createdAt
    }

    public static func persistenceKey(for date: String) -> String {
        return date
    }

    public static var databaseTableName: String {
        return "mealLocalEntity"
    }
}

public extension MealLocalEntity {
    init(date: String, meal: Meal) {
        let encoder = JSONEncoder()
        self.init(
            date: date,
            breakfastMeals: (try? String(data: encoder.encode(meal.breakfast.meals), encoding: .utf8)) ?? "[]",
            breakfastCal: meal.breakfast.cal,
            lunchMeals: (try? String(data: encoder.encode(meal.lunch.meals), encoding: .utf8)) ?? "[]",
            lunchCal: meal.lunch.cal,
            dinnerMeals: (try? String(data: encoder.encode(meal.dinner.meals), encoding: .utf8)) ?? "[]",
            dinnerCal: meal.dinner.cal
        )
    }

    func toMeal() -> Meal {
        let decoder = JSONDecoder()
        let breakfastMealArray = (try? decoder.decode([String].self, from: Data(breakfastMeals.utf8))) ?? []
        let lunchMealArray = (try? decoder.decode([String].self, from: Data(lunchMeals.utf8))) ?? []
        let dinnerMealArray = (try? decoder.decode([String].self, from: Data(dinnerMeals.utf8))) ?? []

        return Meal(
            breakfast: Meal.SubMeal(meals: breakfastMealArray, cal: breakfastCal),
            lunch: Meal.SubMeal(meals: lunchMealArray, cal: lunchCal),
            dinner: Meal.SubMeal(meals: dinnerMealArray, cal: dinnerCal)
        )
    }
}
