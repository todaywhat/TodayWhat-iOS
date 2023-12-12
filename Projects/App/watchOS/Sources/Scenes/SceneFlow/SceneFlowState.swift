import Combine

final class SceneFlowState: ObservableObject {
    @Published var sceneFlow = SceneFlow.root
}
