import ComposableArchitecture
import Foundation

public struct SchoolSettingCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var school = ""
        public var grade = ""
        public var `class` = ""
        public var major = ""
        public var selectedSchool: School?
        public var isFocusedSchool = false
        public var schoolMajorSheetCore: SchoolMajorSheetCore.State?
        public var isPresentedMajorSheet = false
        public var schoolList: [School] = []
        public var schoolMajorList: [String] = []
        public var isError = false
        public var errorMessage = ""

        public var titleMessage: String {
            if school.isEmpty {
                return "학교 이름을 입력해주세요!"
            } else if grade.isEmpty {
                return "몇학년 이신가요?"
            } else if `class`.isEmpty {
                return "몇반 이신가요?"
            } else if major.isEmpty && !schoolMajorList.isEmpty {
                return "학과를 선택해주세요!"
            } else {
                return "입력하신 정보가 정확한가요?"
            }
        }
        public var nextButtonTitle: String {
            if !major.isEmpty || schoolMajorList.isEmpty {
                return "확인"
            }
            return "다음"
        }

        public init() {}
    }

    public enum Action: Equatable {
        case schoolChanged(String)
        case schoolFocusedChanged(Bool)
        case gradeChanged(String)
        case classChanged(String)
        case majorChanged(String)
        case schoolListResponse(TaskResult<[School]>)
        case schoolMajorListResponse(TaskResult<[String]>)
        case schoolRowDidSelect(School)
        case nextButtonDidTap
        case majorTextFieldDidTap
        case majorSheetDismissed
        case schoolMajorSheetCore(SchoolMajorSheetCore.Action)
    }

    @Dependency(\.schoolClient) var schoolClient

    struct SchoolDebounceID: Hashable {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .schoolChanged(school):
                state.school = school
                return .task { [school = state.school] in
                    .schoolListResponse(
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

            case let .schoolMajorListResponse(.success(majorList)):
                state.schoolMajorList = majorList

            case let .schoolMajorListResponse(.failure(error)):
                state.isError = true
                state.errorMessage = error.localizedDescription

            case let .schoolRowDidSelect(school):
                state.selectedSchool = school
                state.school = school.name
                state.isFocusedSchool = false
                return .task {
                    .schoolMajorListResponse(
                        await TaskResult {
                            try await schoolClient.fetchSchoolsMajorList(school.orgCode, school.schoolCode)
                        }
                    )
                }

            case .nextButtonDidTap:
                if state.major.isEmpty && !state.schoolMajorList.isEmpty {
                    state.schoolMajorSheetCore = .init(majorList: state.schoolMajorList, selectedMajor: state.major)
                    state.isPresentedMajorSheet = true
                }

            case .majorTextFieldDidTap:
                state.schoolMajorSheetCore = .init(majorList: state.schoolMajorList, selectedMajor: state.major)
                state.isPresentedMajorSheet = true

            case let .schoolMajorSheetCore(.majorRowDidSelect(major)):
                state.major = major
                state.schoolMajorSheetCore = nil
                state.isPresentedMajorSheet = false

            case .majorSheetDismissed:
                state.schoolMajorSheetCore = nil
                state.isPresentedMajorSheet = false
            
            default:
                return .none
            }
            return .none
        }
        .ifLet(\.schoolMajorSheetCore, action: /Action.schoolMajorSheetCore) {
            SchoolMajorSheetCore()
        }
    }
}
