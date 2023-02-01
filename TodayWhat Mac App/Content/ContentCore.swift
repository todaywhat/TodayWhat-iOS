import ComposableArchitecture
import Entity
import Foundation
import TimeTableClient
import MealClient

public struct ContentCore: ReducerProtocol {
    public init() {}
    

    public struct State: Equatable {
        public var selectedPart: DisplayInfoPart = .breakfast
        public var meal: Meal?
        public var timetables: [TimeTable] = []
    }

    public enum Action: Equatable {
        case onAppear
        case partDidSelect(DisplayInfoPart)
        case mealResponse(TaskResult<Meal>)
        case timetableResponse(TaskResult<[TimeTable]>)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .merge(
                .task {
                    .mealResponse(await TaskResult { try await mealClient.fetchMeal(Date()) })
                },
                .task {
                    .timetableResponse(await TaskResult { try await timeTableClient.fetchTimeTable(Date()) })
                }
            )
            
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

        case let .timetableResponse(.success(timetables)):
            state.timetables = timetables

        case .timetableResponse(.failure(_)):
            state.timetables = []
        }

        return .none
    }
}
