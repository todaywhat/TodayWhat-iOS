import UIKit
import Dependencies
import UserDefaultsClient
import WatchConnectivity

final class AppDelegate: UIResponder, UIApplicationDelegate {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    var session: WCSession!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        session = WCSession.default
        if WCSession.isSupported(), session.isWatchAppInstalled {
            session.delegate = self
            session.activate()
        }

        return true
    }
}

extension AppDelegate: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        guard
            let type = userDefaultsClient.getValue(key: .schoolType, type: String.self),
            let code = userDefaultsClient.getValue(key: .schoolCode, type: String.self),
            let orgCode = userDefaultsClient.getValue(key: .orgCode, type: String.self),
            let grade = userDefaultsClient.getValue(key: .grade, type: Int.self),
            let `class` = userDefaultsClient.getValue(key: .class, type: Int.self)
        else {
            return
        }
        let major = userDefaultsClient.getValue(key: .major, type: String.self) as Any
        replyHandler(
            [
                "type": type,
                "code": code,
                "orgCode": orgCode,
                "major": major,
                "grade": grade,
                "class": `class`
            ]
        )
    }
}
