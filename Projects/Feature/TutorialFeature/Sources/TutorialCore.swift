import ComposableArchitecture
import TutorialClient

public struct TutorialCore: Reducer {
    public init() {}
    public struct State: Equatable {
        public var tutorialList: [TutorialEntity] = []
    
        public init() {}
    }

    public enum Action {
        case onAppear
        case tutorialResponse(TaskResult<[TutorialEntity]>)
    }

    @Dependency(\.tutorialClient) var tutorialClient

    public var body: some ReducerOf<TutorialCore> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let task = await Action.tutorialResponse(
                        TaskResult {
                            try await tutorialClient.fetchTutorialList()
                        }
                    )
                    await send(task)
                }

            case let .tutorialResponse(.success(tutorialList)):
                state.tutorialList = tutorialList

            case let .tutorialResponse(.failure(error)):
                print(error)
            }
            return .none
        }
    }
}
