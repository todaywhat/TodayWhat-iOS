import ComposableArchitecture
import LocalDatabaseClient
import EnumUtil
import Entity

public struct AllergySettingCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var selectedAllergyList: [AllergyType] = []
        public var isSaved = false
        public var allergyDidTap = false
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case saveButtonDidTap
        case allergyDidSelect(AllergyType)
    }

    @Dependency(\.localDatabaseClient) var localDatabaseClient

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            do {
                let records = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                    .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }
                state.selectedAllergyList = records
            } catch {
                state.selectedAllergyList = []
            }

        case let .allergyDidSelect(allergy):
            if state.selectedAllergyList.contains(allergy) {
                state.selectedAllergyList.removeAll { $0 == allergy }
            } else {
                state.selectedAllergyList.append(allergy)
            }
            state.allergyDidTap = true

        case .saveButtonDidTap:
            do {
                try localDatabaseClient.deleteAll(record: AllergyLocalEntity.self)
                try localDatabaseClient.save(
                    records: state.selectedAllergyList.map { AllergyLocalEntity(allergy: $0.rawValue) }
                )
                state.isSaved = true
            } catch { }

        default:
            return .none
        }
        return .none
    }
}
