import ComposableArchitecture
import Entity
import Foundation
import TimeTableClient
import MealClient

struct ContentCore: ReducerProtocol {
    struct State: Equatable {
        var selectedInfoType: DisplayInfoType = .breakfast
        var meal: Meal?
        var timetables: [TimeTable] = []
        var settingsCore: SettingsCore.State?
        var selectedPartMeal: Meal.SubMeal? {
            meal?.mealByPart(part: selectedInfoType)
        }
    }

    enum Action: Equatable {
        case onAppear
        case displayInfoTypeDidSelect(DisplayInfoType)
        case mealResponse(TaskResult<Meal>)
        case timetableResponse(TaskResult<[TimeTable]>)
        case settingsCore(SettingsCore.Action)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient

    var body: some ReducerProtocolOf<ContentCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.meal = .init(
                    breakfast: .init(meals: ["볶음밥", "아무튼 밥", "대충 밥"], cal: 478),
                    lunch: .init(meals: [], cal: 0),
                    dinner: .init(meals: [], cal: 0)
                )
                state.timetables = [
                    .init(perio: 1, content: "앱 프로그래밍"),
                    .init(perio: 2, content: "앱 프로그래밍"),
                    .init(perio: 3, content: "앱 프로그래밍"),
                    .init(perio: 4, content: "겨울방학"),
                    .init(perio: 5, content: "겨울방학"),
                    .init(perio: 6, content: "겨울방학"),
                    .init(perio: 7, content: "겨울방학")
                ]
    //            return .merge(
    //                .task {
    //                    .mealResponse(await TaskResult { try await mealClient.fetchMeal(Date()) })
    //                },
    //                .task {
    //                    .timetableResponse(await TaskResult { try await timeTableClient.fetchTimeTable(Date()) })
    //                }
    //            )
                
            case let .displayInfoTypeDidSelect(part):
                switch part {
                case .settings:
                    state.settingsCore = .init()

                default:
                    state.settingsCore = nil
                }
                state.selectedInfoType = part

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

            default:
                return .none
            }

            return .none
        }
        .ifLet(\.settingsCore, action: /Action.settingsCore) {
            SettingsCore()
        }
    }
}

private extension Meal {
    func mealByPart(part: DisplayInfoType) -> Meal.SubMeal {
        switch part {
        case .breakfast:
            return breakfast

        case .lunch:
            return lunch

        case .dinner:
            return dinner

        default:
            return breakfast
        }
    }
}
