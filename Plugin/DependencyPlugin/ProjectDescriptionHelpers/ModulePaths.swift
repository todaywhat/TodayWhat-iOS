import Foundation

// swiftlint: disable all
public enum ModulePaths {
    case feature(Feature)
    case domain(Domain)
    case core(Core)
    case shared(Shared)
    case userInterface(UserInterface)
}

extension ModulePaths: MicroTargetPathConvertable {
    public func targetName(type: MicroTargetType) -> String {
        switch self {
        case let .feature(module as any MicroTargetPathConvertable),
            let .domain(module as any MicroTargetPathConvertable),
            let .core(module as any MicroTargetPathConvertable),
            let .shared(module as any MicroTargetPathConvertable),
            let .userInterface(module as any MicroTargetPathConvertable):
            return module.targetName(type: type)
        }
    }
}

public extension ModulePaths {
    enum Feature: String, MicroTargetPathConvertable {
        case TutorialFeature
        case TimeTableFeature
        case SplashFeature
        case SettingsFeature
        case SchoolSettingFeature
        case SchoolMajorSheetFeature
        case RootFeature
        case NoticeFeature
        case ModifyTimeTableFeature
        case MealFeature
        case MainFeature
        case AllergySettingFeature
        case BaseFeature
    }
}

public extension ModulePaths {
    enum Domain: String, MicroTargetPathConvertable {
        case BaseDomain
    }
}

public extension ModulePaths {
    enum Core: String, MicroTargetPathConvertable {
        case CoreKit
    }
}

public extension ModulePaths {
    enum Shared: String, MicroTargetPathConvertable {
        case KeychainClient
        case TutorialClient
        case DeviceUtil
        case TWLog
        case ComposableArchitectureWrapper
        case FirebaseWrapper
        case Entity
        case DataMapping
        case SwiftUIUtil
        case FoundationUtil
        case EnumUtil
        case DateUtil
        case ConstantUtil
        case UserDefaultsClient
        case TimeTableClient
        case SchoolClient
        case NoticeClient
        case NeisClient
        case MealClient
        case LocalDatabaseClient
        case ITunesClient
        case DeviceClient
        case GlobalThirdPartyLibrary
    }
}

public extension ModulePaths {
    enum UserInterface: String, MicroTargetPathConvertable {
        case DesignSystem
    }
}

public enum MicroTargetType: String {
    case interface = "Interface"
    case sources = ""
    case testing = "Testing"
    case unitTest = "Tests"
    case demo = "Demo"
}

public protocol MicroTargetPathConvertable {
    func targetName(type: MicroTargetType) -> String
}

public extension MicroTargetPathConvertable where Self: RawRepresentable {
    func targetName(type: MicroTargetType) -> String {
        "\(self.rawValue)\(type.rawValue)"
    }
}
