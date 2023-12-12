import SwiftUI
import Dependencies
import UserDefaultsClient
import SwiftUIUtil

struct RootView: View {
    @EnvironmentObject var sceneFlowState: SceneFlowState
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    var body: some View {
        ZStack {
            switch sceneFlowState.sceneFlow {
            case .root:
                EmptyView()

            case .main:
                MainView()
                    .environmentObject(sceneFlowState)

            case .setting:
                SettingView()
                    .environmentObject(sceneFlowState)
            }
        }
        .onLoad {
            guard
                let code = userDefaultsClient.getValue(.schoolCode) as? String,
                !code.isEmpty,
                let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
                !orgCode.isEmpty,
                userDefaultsClient.getValue(.grade) as? Int != nil,
                userDefaultsClient.getValue(.class) as? Int != nil,
                let type = userDefaultsClient.getValue(.schoolType) as? String,
                !type.isEmpty
            else {
                sceneFlowState.sceneFlow = .setting
                return
            }
            sceneFlowState.sceneFlow = .main
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
