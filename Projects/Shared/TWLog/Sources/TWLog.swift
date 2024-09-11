import FirebaseAnalytics
import Foundation
import OSLog

fileprivate extension OSLog {
    static let subSystem = Bundle.main.bundleIdentifier ?? ""
    static let debug = OSLog(subsystem: subSystem, category: "DEBUG")
    static let event = OSLog(subsystem: subSystem, category: "EVENT")
    static let error = OSLog(subsystem: subSystem, category: "ERROR")
}

/**
 * 효과적인 로깅을 위한 객체입니다.
 * - debug: 개발 중 디버깅 시 사용하기 위한 level
 * - event: 사용자 행동 로그를 위한 level
 * - error: 런타임 중 나타난 에러를 위한 level
 */
public enum TWLog {
    fileprivate enum Level {
        case debug
        case event
        case error

        fileprivate var prefix: String {
            switch self {
            case .debug: "✨"
            case .event: "🎃"
            case .error: "❌"
            }
        }

        fileprivate var category: String {
            switch self {
            case .debug: "DEBUG"
            case .event: "EVENT"
            case .error: "ERROR"
            }
        }
    }
}

public extension TWLog {
    static func setUserID(id: String) {
        Analytics.setUserID(id)

        TWLog.log("Set UserID : \(id)", level: .event)
    }

    static func setUserProperty(key: String, value: String?) {
        Analytics.setUserProperty(value, forName: key)

        TWLog.log("Set UserProperty : [\(key) = \(value ?? "nil")]", level: .event)
    }

    static func setUserProperty(property: TWUserProperty, value: String?) {
        Self.setUserProperty(key: property.rawValue, value: value)
    }

    static func debug(_ message: Any) {
        TWLog.log(message, level: .debug)
    }

    static func event(_ eventLog: any EventLog) {
        #if PROD
        Analytics.logEvent(eventLog.name, parameters: eventLog.params)
        #endif
        TWLog.log("Logged \(eventLog.name)\n\(eventLog.params)", level: .event)
    }

    static func error(_ message: Any) {
        TWLog.log(message, level: .error)
    }
}

private extension TWLog {
    static func log(_ message: Any, level: Level) {
        #if DEV || STAGE
        let logger = Logger(subsystem: OSLog.subSystem, category: level.category)
        let logMessage = "[\(level.prefix) \(level.category)] > \(message)"
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .event:
            logger.info("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        }
        #endif
    }
}
