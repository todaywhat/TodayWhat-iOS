import BaseFeature
import ComposableArchitecture
import Entity
import EnumUtil
import LocalDatabaseClient
import TWLog

public struct AllergySettingCore: Reducer {
    public init() {}
    public struct State: Equatable {
        public var selectedAllergyList: [AllergyType] = []
        public var allergyDidTap = false
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case saveButtonDidTap
        case allergyDidSelect(AllergyType)
    }

    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.dismiss) var dismiss

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            let pageShowedEvengLog = PageShowedEventLog(pageName: "allergy_setting_page")
            TWLog.event(pageShowedEvengLog)

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
                return .run { _ in
                    await dismiss()
                }
            } catch {}

        default:
            return .none
        }
        return .none
    }
}
