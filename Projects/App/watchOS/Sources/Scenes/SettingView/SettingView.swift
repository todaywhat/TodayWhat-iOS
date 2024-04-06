import Dependencies
import Entity
import LocalDatabaseClient
import SwiftUI
import UserDefaultsClient

struct SettingView: View {
    @EnvironmentObject var sceneFlowState: SceneFlowState
    @StateObject var watchSessionManager = WatchSessionManager.shared
    @State var isReachable = false
    @State var loadingStateText = "아이폰에서 먼저 학교 설정을 마치고 와주세요!"
    @State var isLoading = false
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    var body: some View {
        VStack {
            Text(loadingStateText)
                .font(.system(size: 14))
                .lineLimit(2)
                .multilineTextAlignment(.center)

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

            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            receiveIPhoneSetting()
        }
        .navigationBarTitleDisplayMode(.large)
    }

    private func receiveIPhoneSetting() {
        isReachable = watchSessionManager.isReachable
        guard WatchSessionManager.shared.isReachable else {
            isReachable = false
            return
        }
        loadingStateText = "아이폰과 연결중이에요... \n시간이 좀 걸릴 수도 있어요!"
        isLoading = true
        WatchSessionManager.shared.sendMessage(
            message: [:]
        ) { items in
            isLoading = false
            guard
                let code = items["code"] as? String,
                let orgCode = items["orgCode"] as? String,
                let grade = items["grade"] as? Int,
                let `class` = items["class"] as? Int,
                let type = items["type"] as? String,
                let isOnModifiedTimeTable = items["isOnModifiedTimeTable"] as? Bool,
                let timeTablesData = items["timeTables"] as? Data
            else {
                return
            }

            // swiftlint: disable force_try
            let timeTables = try! JSONDecoder().decode([ModifiedTimeTableLocalEntity].self, from: timeTablesData)
            // swiftlint: enable force_try
            let dict: [UserDefaultsKeys: Any] = [
                .grade: grade,
                .class: `class`,
                .schoolType: type,
                .orgCode: orgCode,
                .schoolCode: code,
                .isOnModifiedTimeTable: isOnModifiedTimeTable
            ]
            dict.forEach { key, value in
                userDefaultsClient.setValue(key, value)
            }
            if let major = items["major"] as? String {
                userDefaultsClient.setValue(.major, major)
            }
            DispatchQueue.main.async {
                sceneFlowState.sceneFlow = .main
            }
            try? self.localDatabaseClient.save(records: timeTables)
        } error: { error in
            isLoading = false
            loadingStateText = "아이폰의 오늘 뭐임을 켠 상태로 다시 시도해주세요!"
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
