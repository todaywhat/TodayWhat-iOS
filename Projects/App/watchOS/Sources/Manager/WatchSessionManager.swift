import Dependencies
import Entity
import LocalDatabaseClient
import UserDefaultsClient
import WatchConnectivity

final class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    var isReachable: Bool {
        session.isReachable
    }

    static let shared = WatchSessionManager()

    func activate() {
        session.activate()
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        sendMessage(message: [:]) { [weak self] items in
            guard let self else { return }
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
            let timeTables = self.decodeTimeTables(data: timeTablesData)
            let dict: [UserDefaultsKeys: Any] = [
                .grade: grade,
                .class: `class`,
                .schoolType: type,
                .orgCode: orgCode,
                .schoolCode: code,
                .isOnModifiedTimeTable: isOnModifiedTimeTable
            ]
            dict.forEach { key, value in
                self.userDefaultsClient.setValue(key, value)
            }
            if let major = items["major"] as? String {
                self.userDefaultsClient.setValue(.major, major)
            }
            try? self.localDatabaseClient.save(records: timeTables)
        }
    }

    override private init() {
        session = .default
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    private let session: WCSession

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("RECEIVE : \(message)")
        guard
            let code = message["code"] as? String,
            let orgCode = message["orgCode"] as? String,
            let grade = message["grade"] as? Int,
            let `class` = message["class"] as? Int,
            let type = message["type"] as? String,
            let isOnModifiedTimeTable = message["isOnModifiedTimeTable"] as? Bool,
            let timeTablesData = message["timeTables"] as? Data
        else {
            return
        }
        let timeTables = decodeTimeTables(data: timeTablesData)
        let dict: [UserDefaultsKeys: Any] = [
            .grade: grade,
            .class: `class`,
            .schoolType: type,
            .orgCode: orgCode,
            .schoolCode: code,
            .isOnModifiedTimeTable: isOnModifiedTimeTable
        ]
        dict.forEach { key, value in
            self.userDefaultsClient.setValue(key, value)
        }
        if let major = message["major"] as? String {
            self.userDefaultsClient.setValue(.major, major)
        }
        try? self.localDatabaseClient.save(records: timeTables)
    }

    func sendMessage(
        message: [String: Any],
        reply: @escaping ([String: Any]) -> Void,
        error: ((Error) -> Void)? = nil
    ) {
        guard session.activationState == .activated else {
            return
        }
        #if os(iOS)
        guard session.isWatchAppInstalled else {
            return
        }
        #endif
        session.sendMessage(message, replyHandler: reply, errorHandler: error)
    }

    // swiftlint: disable force_try
    private func decodeTimeTables(data: Data) -> [ModifiedTimeTableLocalEntity] {
        let entities = try! JSONDecoder().decode([ModifiedTimeTableLocalEntity].self, from: data)
        return entities
    }
    // swiftlint: enable force_try
}
