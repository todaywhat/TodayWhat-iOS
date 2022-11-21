import Dependencies
import Foundation
import XCTestDynamicOverlay
import NeisClient
import Entity
import ResponseDTO
import UserDefaultsClient

public struct MealClient: Sendable {
    public var fetchMeal: @Sendable () async throws -> [Meal]
}

extension MealClient: DependencyKey {
    public static var liveValue: MealClient = MealClient(
        fetchMeal: {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            guard
                let orgCode = userDefaultsClient.orgCode,
                let code = userDefaultsClient.code
            else {
                return []
            }

            @Dependency(\.neisClient) var neisClient

            let response = try await neisClient.fetchDataOnNeis(
                "schoolInfo",
                queryItem: [
                    .init(name: "KEY", value: ""),
                    .init(name: "Type", value: "json"),
                    .init(name: "pIndex", value: "1"),
                    .init(name: "pSize", value: "10")
                ],
                key: "schoolInfo",
                type: [SingleSchoolResponseDTO].self
            )
            return []
        }
    )
}

extension DependencyValues {
    public var mealClient: MealClient {
        get { self[MealClient.self] }
        set { self[MealClient.self] = newValue }
    }
}
