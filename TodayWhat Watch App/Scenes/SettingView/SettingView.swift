import SwiftUI
import Dependencies
import UserDefaultsClient

struct SettingView: View {
    @EnvironmentObject var sceneFlowState: SceneFlowState
    @StateObject var watchSessionManager = WatchSessionManager.shared
    @State var isReachable = false
    @State var loadingStateText = "아이폰에서 먼저 학교 설정을 마치고 와주세요!"
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    var body: some View {
        VStack {
            Text(loadingStateText)
                .font(.system(size: 14))

            Button {
                receiveIPhoneSetting()
            } label: {
                Text("데이터 가져오기")
            }

            HStack {
                Text("아이폰과 연결 상태")
                    .font(.system(size: 12))

                Text(isReachable ? "ON" : "OFF")
                    .font(.system(size: 12))
            }
        }
        .onAppear {
            receiveIPhoneSetting()
        }
    }

    private func receiveIPhoneSetting() {
        isReachable = watchSessionManager.isReachable
        guard WatchSessionManager.shared.isReachable else {
            return
        }
        loadingStateText = "아이폰과 연결중이에요..."
        WatchSessionManager.shared.sendMessage(
            message: [:]
        ) { items in
            guard
                let code = items["code"] as? String,
                let orgCode = items["orgCode"] as? String,
                let grade = items["grade"] as? Int,
                let `class` = items["class"] as? Int,
                let type = items["type"] as? String
            else {
                return
            }
            let major = items["major"] as Any
            let dict: [UserDefaultsKeys: Any] = [
                .grade: grade,
                .class: `class`,
                .schoolType: type,
                .orgCode: orgCode,
                .schoolCode: code,
                .major: major
            ]
            dict.forEach { key, value in
                userDefaultsClient.setValue(key, value)
            }
            DispatchQueue.main.async {
                sceneFlowState.sceneFlow = .root
            }
        } error: { error in
            loadingStateText = "아이폰과 연결이 실패했어요..."
        }
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
