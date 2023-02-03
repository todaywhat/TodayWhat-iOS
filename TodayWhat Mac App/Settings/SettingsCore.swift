import ComposableArchitecture
import Entity
import LocalDatabaseClient
import SchoolClient
import UserDefaultsClient

struct SettingsCore: ReducerProtocol {
    enum FocusState: Hashable{
        case school
        case grade
        case `class`
    }

    struct State: Equatable {
        var focusState: FocusState? = nil
        var schoolText = ""
        var gradeText = ""
        var classText = ""
        var majorText = ""
        var schoolList: [School] = []
        var schoolMajorList: [String] = []
        var isLoading = false
        var isSkipWeekend = false
    }

    enum Action: Equatable {
        case onAppear
        case setFocusState(FocusState?)
        case setSchoolText(String)
        case setGradeText(String)
        case setClassText(String)
        case setIsSkipWeekend(Bool)
        case schoolListResponse(TaskResult<[School]>)
        case schoolMajorListResponse(TaskResult<[String]>)
        case schoolDidSelect(School)
        case majorDidSelect(String)
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.schoolClient) var schoolClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            guard
                let school = userDefaultsClient.getValue(key: .school, type: String.self),
                let grade = userDefaultsClient.getValue(key: .grade, type: Int.self),
                let `class` = userDefaultsClient.getValue(key: .class, type: Int.self)
            else {
                break
            }
            state.schoolText = school
            state.gradeText = "\(grade)"
            state.classText = "\(`class`)"
            state.isSkipWeekend = userDefaultsClient.getValue(key: .isSkipWeekend, type: Bool.self) ?? false
            state.majorText = userDefaultsClient.getValue(key: .major, type: String.self) ?? ""
            let majorList = try? localDatabaseClient.readRecords(as: SchoolMajorLocalEntity.self)
                .map { $0.major }
            state.schoolMajorList = majorList ?? []

        case let .setFocusState(focusState):
            state.focusState = focusState

        case let .setSchoolText(school):
            state.schoolText = school
            state.isLoading = true
            return .task {
                await .schoolListResponse(
                    TaskResult {
                        try await schoolClient.fetchSchoolList(school)
                    }
                )
            }

        case let .setGradeText(grade):
            state.gradeText = grade
            if !grade.isEmpty {
                userDefaultsClient.setValue(.grade, Int(grade) ?? 1)
            }

        case let .setClassText(`class`):
            state.classText = `class`
            if !`class`.isEmpty {
                userDefaultsClient.setValue(.class, Int(`class`) ?? 1)
            }

        case let .setIsSkipWeekend(isSkipWeekend):
            state.isSkipWeekend = isSkipWeekend
            userDefaultsClient.setValue(.isSkipWeekend, isSkipWeekend)

        case let .schoolListResponse(.success(schoolList)):
            state.schoolList = schoolList
            state.isLoading = false

        case .schoolListResponse(.failure(_)):
            state.isLoading = false

        case let .schoolMajorListResponse(.success(majorList)):
            var majorList = majorList
            majorList.insert("", at: 0)
            state.schoolMajorList = majorList
            try? localDatabaseClient.deleteAll(record: SchoolMajorLocalEntity.self)
            try? localDatabaseClient.save(records: majorList.map { SchoolMajorLocalEntity(major: $0) })
            state.isLoading = false

        case .schoolMajorListResponse(.failure(_)):
            state.isLoading = false

        case let .schoolDidSelect(school):
            state.schoolText = school.name
            state.majorText = ""
            state.focusState = nil
            userDefaultsClient.setValue(.orgCode, school.orgCode)
            userDefaultsClient.setValue(.schoolType, school.schoolType.rawValue)
            userDefaultsClient.setValue(.schoolCode, school.schoolCode)
            userDefaultsClient.setValue(.school, school.name)
            return .task { [orgCode = school.orgCode, schoolCode = school.schoolCode] in
                await .schoolMajorListResponse(
                    TaskResult {
                        try await schoolClient.fetchSchoolsMajorList(orgCode, schoolCode)
                    }
                )
            }

        case let .majorDidSelect(major):
            state.majorText = major
            userDefaultsClient.setValue(.major, major)

        default:
            return .none
        }
        
        return .none
    }
}
