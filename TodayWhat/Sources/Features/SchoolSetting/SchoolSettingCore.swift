import ComposableArchitecture
import Foundation

public struct SchoolSettingCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var selectedSchool: School?
        public var isFocusedSchool = false
        public var schoolList: [School] = []
        public var isError = false
        public var errorMessage = ""

        public var titleMessage: String {
            if school.isEmpty {
                return "학교 이름을 입력해주세요"
            } else if grade.isEmpty {
                return "몇학년 이신가요?"
            } else if `class`.isEmpty {
                return "몇반 이신가요"
            } else {
                return ""
            }
        }
        public init() {}
    }

    public enum Action: Equatable {
        case schoolChanged(String)
        case schoolFocusedChanged(Bool)
        case gradeChanged(String)
        case classChanged(String)
        case schoolListResponse(TaskResult<[School]>)
        case schoolRowDidSelect(School)
    }

    @Dependency(\.schoolClient) var schoolClient

    struct SchoolDebounceID: Hashable {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .schoolChanged(school):
                state.school = school
                return .task { [school = state.school] in
                    return .schoolListResponse(
                        await TaskResult {
                            try await schoolClient.fetchSchoolList(school)
                        }
                    )
                }
                .debounce(id: SchoolDebounceID(), for: .milliseconds(150), scheduler: DispatchQueue.main)

            case let .schoolFocusedChanged(focused):
                state.isFocusedSchool = focused

            case let .gradeChanged(grade):
                state.grade = "\(grade)"

            case let .classChanged(`class`):
                state.class = "\(`class`)"

            case let .schoolListResponse(.success(list)):
                state.schoolList = list

            case let .schoolListResponse(.failure(error)):
                state.isError = true
                state.errorMessage = error.localizedDescription

            case let .schoolRowDidSelect(school):
                state.selectedSchool = school
                state.school = school.name
                state.isFocusedSchool = false
            
            default:
                return .none
            }
            return .none
        }
    }
}
