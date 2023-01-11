import SwiftUI
import Dependencies
import UserDefaultsClient

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
        .onAppear {
            guard
                let code = userDefaultsClient.getValue(key: .schoolCode, type: String.self),
                !code.isEmpty,
                let orgCode = userDefaultsClient.getValue(key: .orgCode, type: String.self),
                !orgCode.isEmpty,
                userDefaultsClient.getValue(key: .grade, type: Int.self) != nil,
                userDefaultsClient.getValue(key: .class, type: Int.self) != nil,
                let type = userDefaultsClient.getValue(key: .schoolType, type: String.self),
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
