import ConfigurationPlugin
import Foundation
import ProjectDescription

public enum GenerateEnvironment: String {
    case ci = "CI"
    case cd = "CD"
    case dev = "DEV"
}

let environment = ProcessInfo.processInfo.environment["TUIST_ENV"] ?? ""
public let generateEnvironment = GenerateEnvironment(rawValue: environment) ?? .dev

public extension GenerateEnvironment {
    var iOSScripts: [TargetScript] {
        switch self {
        case .ci:
            return []

        case .cd:
            return [.firebaseInfoByIOSConfiguration, .firebaseCrashlytics]

        case .dev:
            return [.swiftLint, .firebaseCrashlytics, .firebaseInfoByIOSConfiguration]
        }
    }

    var macOSScripts: [TargetScript] {
        switch self {
        case .ci:
            return [.launchAtLogin]

        case .cd:
            return [.firebaseInfoByMacOSConfiguration, .launchAtLogin]

        case .dev:
            return [.swiftLint, .firebaseInfoByMacOSConfiguration, .launchAtLogin]
        }
    }
}
