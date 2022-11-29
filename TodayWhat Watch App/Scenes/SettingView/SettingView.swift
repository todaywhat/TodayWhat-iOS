import SwiftUI
import Dependencies
import UserDefaultsClient

struct SettingView: View {
    @EnvironmentObject var sceneFlowState: SceneFlowState
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    var body: some View {
        VStack {
            Text("아이폰에서 먼저 학교 설정을 마치고 와주세요!")

            Button {
                receiveIPhoneSetting()
            } label: {
                Text("데이터 가져오기")
            }
        }
        .onAppear {
            receiveIPhoneSetting()
        }
    }

    private func receiveIPhoneSetting() {
        guard WatchSessionManager.shared.isRechable() else {
            return
        }
        WatchSessionManager.shared.sendMessage(
            message: [:]
        ) { items in
            print(items)
            guard
                let code = items["code"] as? String,
                let orgCode = items["orgCode"] as? String,
                let grade = items["grade"] as? Int,
                let `class` = items["class"] as? Int,
                let type = items["type"]
            else {
                return
            }
            let dict: [UserDefaultsKeys: Any] = [
                .grade: grade,
                .class: `class`,
                .schoolType: type,
                .orgCode: orgCode,
                .schoolCode: code
            ]
            dict.forEach { key, value in
                userDefaultsClient.setValue(key, value)
            }
            DispatchQueue.main.async {
                sceneFlowState.sceneFlow = .root
            }
        }
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
