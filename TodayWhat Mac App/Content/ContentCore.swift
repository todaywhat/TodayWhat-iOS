import ComposableArchitecture
import Entity
import Foundation
import MealClient

public struct ContentCore: ReducerProtocol {
    public init() {}
    

    public struct State: Equatable {
        public var selectedPart: DisplayInfoPart = .breakfast
        public var meal: Meal?
    }

    public enum Action: Equatable {
        case onAppear
        case partDidSelect(DisplayInfoPart)
        case mealResponse(TaskResult<Meal>)
    }

    @Dependency(\.mealClient) var mealClient

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .task {
                .mealResponse(
                    await TaskResult {
                        try await mealClient.fetchMeal(Date())
                    }
                )
            }
            
        case let .partDidSelect(part):
            state.selectedPart = part

        case let .mealResponse(.success(meal)):
            state.meal = meal

        case .mealResponse(.failure(_)):
            state.meal = .init(
                breakfast: .init(meals: [], cal: 0),
                lunch: .init(meals: [], cal: 0),
                dinner: .init(meals: [], cal: 0)
            )
        }

        return .none
    }
}
