import ComposableArchitecture

public struct SchoolMajorSheetCore: Reducer {
    public init() {}
    public struct State: Equatable {
        public var majorList: [String] = []
        public var selectedMajor: String?

        public init(
            majorList: [String],
            selectedMajor: String? = nil
        ) {
            self.majorList = majorList
            self.selectedMajor = selectedMajor
        }
    }

    public enum Action: Equatable {
        case majorRowDidSelect(String)
    }

    public var body: some ReducerOf<SchoolMajorSheetCore> {
        Reduce { state, action in
            switch action {
            case let .majorRowDidSelect(major):
                state.selectedMajor = major
            
            default:
                return .none
            }
            return .none
        }
    }
}
