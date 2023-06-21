import ComposableArchitecture
import Entity

public struct NoticeCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var emegencyNotice: EmegencyNotice

        public init(emegencyNotice: EmegencyNotice) {
            self.emegencyNotice = emegencyNotice
        }
    }

    public enum Action {
        
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
