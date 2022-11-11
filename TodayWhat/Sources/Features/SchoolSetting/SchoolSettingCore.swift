import ComposableArchitecture

public struct SchoolSettingCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var isFocusedSchool = false

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
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .schoolChanged(school):
                state.school = school

            case let .schoolFocusedChanged(focused):
                state.isFocusedSchool = focused

            case let .gradeChanged(grade):
                state.grade = "\(grade)"

            case let .classChanged(`class`):
                state.class = "\(`class`)"
            
            default:
                return .none
            }
            return .none
        }
    }
}
