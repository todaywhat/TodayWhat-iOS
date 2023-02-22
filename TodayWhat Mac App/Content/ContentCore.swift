import ComposableArchitecture
import Entity
import Foundation
import TimeTableClient
import MealClient
import UserDefaultsClient

struct ContentCore: ReducerProtocol {
    struct State: Equatable {
        var selectedInfoType: DisplayInfoType = .breakfast
        var meal: Meal?
        var timetables: [TimeTable] = []
        var settingsCore: SettingsCore.State?
        var allergyCore: AllergyCore.State?
        var isNotSetSchool = false
        var selectedPartMeal: Meal.SubMeal? {
            meal?.mealByPart(part: selectedInfoType)
        }
    }

    enum Action: Equatable {
        case onAppear
        case refresh
        case displayInfoTypeDidSelect(DisplayInfoType)
        case mealResponse(TaskResult<Meal>)
        case timetableResponse(TaskResult<[TimeTable]>)
        case settingsCore(SettingsCore.Action)
        case alleryCore(AllergyCore.Action)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    var body: some ReducerProtocolOf<ContentCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard
                    let school = userDefaultsClient.getValue(.school) as? String,
                    !school.isEmpty
                else {
                    state.isNotSetSchool = true
                    return .none
                }
                state.isNotSetSchool = false

                return .merge(
                    .task {
                        .mealResponse(await TaskResult { try await mealClient.fetchMeal(Date()) })
                    },
                    .task {
                        .timetableResponse(await TaskResult { try await timeTableClient.fetchTimeTable(Date()) })
                    }
                )

            case .refresh:
                return .run { send in
                    await send(.onAppear)
                }
                
            case let .displayInfoTypeDidSelect(part):
                switch part {
                case .breakfast, .lunch, .dinner, .timetable:
                    state.settingsCore = nil
                    state.allergyCore = nil
                    state.selectedInfoType = part
                    return .run { send in
                        await send(.onAppear)
                    }

                case .allergy:
                    state.allergyCore = .init()

                case .settings:
                    state.settingsCore = .init()

                default:
                    state.settingsCore = nil
                    state.allergyCore = nil
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
        .ifLet(\.allergyCore, action: /Action.alleryCore) {
            AllergyCore()
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
