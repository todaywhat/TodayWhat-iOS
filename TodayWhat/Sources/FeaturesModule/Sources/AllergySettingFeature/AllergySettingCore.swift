import ComposableArchitecture
import LocalDatabaseClient
import EnumUtil
import Entity

public struct AllergySettingCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var selectedAllergyList: [AllergyType] = []
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case onWillDisappear
        case allergyDidSelect(AllergyType)
    }

    @Dependency(\.localDatabaseClient) var localDatabaseClient

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
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

            case .onWillDisappear:
                do {
                    try localDatabaseClient.deleteAll(record: AllergyLocalEntity.self)
                    try localDatabaseClient.save(
                        records: state.selectedAllergyList.map { AllergyLocalEntity(allergy: $0.rawValue) }
                    )
                } catch { }

            default:
                return .none
            }
            
            return .none
        }
    }
}
