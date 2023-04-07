import AppKit.NSApplication
import ComposableArchitecture
import Dispatch
import Entity
import EnumUtil
import Foundation
import TimeTableClient
import MealClient
import UserDefaultsClient
import LocalDatabaseClient

struct ContentCore: ReducerProtocol {
    struct State: Equatable {
        var selectedInfoType: DisplayInfoType = .breakfast
        var meal: Meal?
        var timetables: [TimeTable] = []
        var allergyList: [AllergyType] = []
        var settingsCore: SettingsCore.State?
        var allergyCore: AllergyCore.State?
        var isNotSetSchool = false
        var selectedPartMeal: Meal.SubMeal? {
            meal?.mealByPart(part: selectedInfoType)
        }
    }

    enum Action: Equatable {
        case popoverOpen
        case fetchData
        case refresh
        case exit
        case displayInfoTypeDidSelect(DisplayInfoType)
        case mealResponse(TaskResult<Meal>)
        case timetableResponse(TaskResult<[TimeTable]>)
        case settingsCore(SettingsCore.Action)
        case alleryCore(AllergyCore.Action)
    }

    @Dependency(\.mealClient) var mealClient
    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    var body: some ReducerProtocolOf<ContentCore> {
        Reduce { state, action in
            switch action {
            case .popoverOpen:
                let date = Date()
                switch date.hour {
                case 0..<8:
                    state.selectedInfoType = .breakfast

                case 8..<13:
                    state.selectedInfoType = .lunch

                case 13..<20:
                    state.selectedInfoType = .dinner

                default:
                    state.selectedInfoType = .breakfast
                }
                
            case .fetchData:
                guard
                    let school = userDefaultsClient.getValue(.school) as? String,
                    !school.isEmpty
                else {
                    state.isNotSetSchool = true
                    return .none
                }
                state.isNotSetSchool = false
                let allergyList = try? localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                    .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                state.allergyList = allergyList ?? []

                return .merge(
                    .task {
                        .mealResponse(await TaskResult {
                            var targetDate = Date()
                            if targetDate.hour >= 19, userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                                targetDate = targetDate.adding(by: .day, value: 1)
                            }
                            return try await mealClient.fetchMeal(targetDate)
                        })
                    },
                    .task {
                        .timetableResponse(await TaskResult {
                            var targetDate = Date()
                            if targetDate.hour >= 19, userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true {
                                targetDate = targetDate.adding(by: .day, value: 1)
                            }
                            return try await timeTableClient.fetchTimeTable(targetDate)
                        })
                    }
                )

            case .refresh:
                return .run { send in
                    await send(.fetchData)
                }

            case .exit:
                NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    exit(0)
                }
                
            case let .displayInfoTypeDidSelect(part):
                guard state.selectedInfoType != part else { break }
                switch part {
                case .breakfast, .lunch, .dinner, .timetable:
                    state.settingsCore = nil
                    state.allergyCore = nil
                    state.selectedInfoType = part
                    return .run { send in
                        await send(.fetchData)
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
