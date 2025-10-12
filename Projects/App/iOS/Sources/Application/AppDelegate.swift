import Dependencies
import DesignSystem
import Entity
import EnumUtil
import FeatureFlagClient
import Firebase
import FirebaseAnalytics
import FirebaseCore
import FirebaseRemoteConfig
import FirebaseWrapper
import KeychainClient
import LocalDatabaseClient
import TWLog
import UIKit
import UserDefaultsClient
import WatchConnectivity
import WidgetKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.featureFlagClient) var featureFlagClient
    var session: WCSession!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Task {
            do {
                try await RemoteConfig.remoteConfig().fetchAndActivate()
            } catch {
                TWLog.error(error)
            }
        }
        DesignSystemFontFamily.Suit.all.forEach { $0.register() }
        initializeAnalyticsUserID()
        sendUserPropertyWidget()
        session = WCSession.default
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        TWLog.setUserProperty(property: .activeWatch, value: WCSession.default.isWatchAppInstalled ? "true" : "false")

        if let schoolTypeRawString = self.userDefaultsClient.getValue(.schoolType) as? String,
           let schoolType = SchoolType(rawValue: schoolTypeRawString) {
            TWLog.setUserProperty(property: .schoolType, value: schoolType.analyticsValue)
        }

        let isSkipWeekend = self.userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
        TWLog.setUserProperty(property: .isSkipWeekend, value: "\(isSkipWeekend)")

        let isCustomTimeTable = self.userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
        TWLog.setUserProperty(property: .isCustomTimeTable, value: "\(isCustomTimeTable)")

        let isSkipAfterDinner = self.userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true
        TWLog.setUserProperty(property: .isSkipAfterDinner, value: "\(isSkipAfterDinner)")

        do {
            let allergies = try self.localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }

            if allergies.isEmpty {
                TWLog.setUserProperty(property: .allergies, value: nil)
            } else {
                TWLog.setUserProperty(
                    property: .allergies,
                    value: allergies.map(\.analyticsValue).joined(separator: ",")
                )
            }

        } catch {
            TWLog.error(error)
        }

        return true
    }

    func application(
        _ application: UIApplication,
        shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
    ) -> Bool {
        switch extensionPointIdentifier {
        case .keyboard:
            return false

        default:
            return true
        }
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
        let isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
        let timeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
        var dict: [String: Any] = [
            "type": type,
            "code": code,
            "orgCode": orgCode,
            "grade": grade,
            "class": `class`,
            "isOnModifiedTimeTable": isOnModifiedTimeTable,
            "timeTables": encodeTimeTables(timeTables: timeTables ?? [])
        ]
        if let major = userDefaultsClient.getValue(.major) as? String {
            dict["major"] = major
        }

        session.sendMessage(dict, replyHandler: nil) { error in
            TWLog.error(error.localizedDescription)
        }
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
        let isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
        let timeTables = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)
        var reply: [String: Any] = [
            "type": type,
            "code": code,
            "orgCode": orgCode,
            "grade": grade,
            "class": `class`,
            "isOnModifiedTimeTable": isOnModifiedTimeTable,
            "timeTables": encodeTimeTables(timeTables: timeTables ?? [])
        ]
        if let major = userDefaultsClient.getValue(.major) as? String {
            reply["major"] = major
        }

        replyHandler(reply)
    }

    private func sendUserPropertyWidget() {
        WidgetCenter.shared.getCurrentConfigurations { [weak self] widgetInfos in
            guard let self else { return }
            let widgetCount = self.userDefaultsClient.getValue(.widgetCount) as? Int ?? 0

            guard case let .success(infos) = widgetInfos, widgetCount != infos.count else { return }
            self.userDefaultsClient.setValue(.widgetCount, infos.count)

            TWLog.setUserProperty(property: .widgetCount, value: "\(infos.count)")

            let propertyString: String = infos
                .compactMap { (info: WidgetInfo) in
                    let string = WidgetUserPropertyBuiler(widgetInfo: info).buildString()
                    return string
                }
                .joined(separator: ",")

            TWLog.setUserProperty(property: .widget, value: propertyString)
        }
    }

    private func encodeTimeTables(timeTables: [ModifiedTimeTableLocalEntity]) -> Data {
        // swiftlint: disable force_try
        let data = try! JSONEncoder().encode(timeTables)
        // swiftlint: enable force_try
        return data
    }
}

private extension AppDelegate {
    func initializeAnalyticsUserID() {
        if let uuid = keychainClient.getValue(.uuid) {
            TWLog.setUserID(id: uuid)
        } else {
            let newUUID = UUID().uuidString
            keychainClient.setValue(.uuid, newUUID)
            TWLog.setUserID(id: newUUID)
        }
    }
}

private struct WidgetUserPropertyBuiler: Sendable {
    private let info: WidgetInfo

    init(widgetInfo: WidgetInfo) {
        self.info = widgetInfo
    }

    func buildString() -> String? {
        switch info.kind {
        case "TodayWhatMealControlWidget":
            return "meal_control_center"
        case "TodayWhatTimeTableControlWidget":
            return "timetable_control_center"
        case "TodayWhatMealWidget":
            return "meal_\(familyToProperty(family: info.family))"
        case "TodayWhatTimeTableWidget":
            return "timetable_\(familyToProperty(family: info.family))"
        case "TodayWhatMealTimeTableWidget":
            return "meal_and_timetable_\(familyToProperty(family: info.family))"
        default:
            assertionFailure("failed to convert widget kind")
            return nil
        }
    }

    private func familyToProperty(family: WidgetFamily) -> String {
        switch family {
        case .systemSmall: return "small"
        case .systemMedium: return "medium"
        case .systemLarge: return "large"
        case .systemExtraLarge: return "extra_large"
        case .accessoryRectangular: return "meal_lockscreen_rectangular"
        case .accessoryCircular: return "lockscreen_circular"
        case .accessoryInline: return "lockscreen_inline"
        }
    }
}
