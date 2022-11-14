import ComposableArchitecture

public struct SchoolMajorSheetCore: ReducerProtocol {
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

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            
            default:
                return .none
            }
        }
    }
}
