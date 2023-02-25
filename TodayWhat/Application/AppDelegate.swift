import UIKit
import Dependencies
import UserDefaultsClient
import WatchConnectivity
import OSLog

final class AppDelegate: UIResponder, UIApplicationDelegate {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    var session: WCSession!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        session = WCSession.default
        if WCSession.isSupported() {
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
    ) {
        guard
            let type = userDefaultsClient.getValue(.schoolType) as? String,
            let code = userDefaultsClient.getValue(.schoolCode) as? String,
            let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
            let grade = userDefaultsClient.getValue(.grade) as? Int,
            let `class` = userDefaultsClient.getValue(.class) as? Int
        else {
            return
        }
        var dict: [String: Any] = [
            "type": type,
            "code": code,
            "orgCode": orgCode,
            "grade": grade,
            "class": `class`
        ]
        if let major = userDefaultsClient.getValue(.major) as? String {
            dict["major"] = major
        }
        
        session.sendMessage(dict, replyHandler: nil)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        guard
            let type = userDefaultsClient.getValue(.schoolType) as? String,
            let code = userDefaultsClient.getValue(.schoolCode) as? String,
            let orgCode = userDefaultsClient.getValue(.orgCode) as? String,
            let grade = userDefaultsClient.getValue(.grade) as? Int,
            let `class` = userDefaultsClient.getValue(.class) as? Int
        else {
            return
        }
        var reply: [String: Any] = [
            "type": type,
            "code": code,
            "orgCode": orgCode,
            "grade": grade,
            "class": `class`
        ]
        if let major = userDefaultsClient.getValue(.major) as? String {
            reply["major"] = major
        }
         
        replyHandler(reply)
    }
}
