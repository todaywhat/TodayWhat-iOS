import ComposableArchitecture

public struct ContentCore: ReducerProtocol {
    public init() {}
    

    public struct State: Equatable {
        var selectedPart: DisplayInfoPart = .breakfast
    }

    public enum Action: Equatable {
        case partDidSelect(DisplayInfoPart)
    }

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .partDidSelect(part):
            state.selectedPart = part
        }

        return .none
    }
}
