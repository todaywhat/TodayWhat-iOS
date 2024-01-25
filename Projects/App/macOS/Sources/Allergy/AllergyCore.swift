import ComposableArchitecture
import Entity
import EnumUtil

struct AllergyCore: ReducerProtocol {
    struct State: Equatable {
        var selectedAllergyList: [AllergyType] = []
    }

    enum Action: Equatable {
        case onAppear
        case allergyDidSelect(AllergyType)
    }

    @Dependency(\.localDatabaseClient) var localDatabaseClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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
            try? localDatabaseClient.deleteAll(record: AllergyLocalEntity.self)
            try? localDatabaseClient.save(
                records: state.selectedAllergyList.map { AllergyLocalEntity(allergy: $0.rawValue) }
            )
        }
        return .none
    }
}
