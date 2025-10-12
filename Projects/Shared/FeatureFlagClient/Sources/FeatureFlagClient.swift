import Dependencies
import FirebaseRemoteConfig
import FirebaseWrapper

public enum FeatureFlagKey: String, Sendable {
    case reviewText = "review_text"
    case enableWeeklyView = "enable_weekly_view"
}

@available(*, deprecated, message: "deprecated")
public struct FeatureFlagClient: Sendable {
    public var getString: @Sendable (FeatureFlagKey) -> String?
    public var getBool: @Sendable (FeatureFlagKey) -> Bool
    public var getNumber: @Sendable (FeatureFlagKey) -> NSNumber
    public var getDictionary: @Sendable (FeatureFlagKey) -> [String: Any]?

    init(
        getString: @Sendable @escaping (FeatureFlagKey) -> String?,
        getBool: @Sendable @escaping (FeatureFlagKey) -> Bool,
        getNumber: @Sendable @escaping (FeatureFlagKey) -> NSNumber,
        getDictionary: @Sendable @escaping (FeatureFlagKey) -> [String: Any]?
    ) {
        RemoteConfig.remoteConfig().setDefaults([
            FeatureFlagKey.reviewText.rawValue: "오늘뭐임을 더 발전시킬 수 있게 리뷰 부탁드려요!" as NSString,
            FeatureFlagKey.enableWeeklyView.rawValue: false as NSNumber
        ] as [String: NSObject])
        self.getString = getString
        self.getBool = getBool
        self.getNumber = getNumber
        self.getDictionary = getDictionary
    }

    public func activate() async throws {
        try await RemoteConfig.remoteConfig().fetchAndActivate()
    }
}

extension FeatureFlagClient: DependencyKey {
    public static var liveValue: FeatureFlagClient = FeatureFlagClient(
        getString: { key in
            RemoteConfig.remoteConfig().configValue(forKey: key.rawValue).stringValue
        },
        getBool: { key in
            RemoteConfig.remoteConfig().configValue(forKey: key.rawValue).boolValue
        },
        getNumber: { key in
            RemoteConfig.remoteConfig().configValue(forKey: key.rawValue).numberValue
        },
        getDictionary: { key in
            RemoteConfig.remoteConfig().configValue(forKey: key.rawValue).jsonValue as? [String: Any]
        }
    )
}

extension FeatureFlagClient: TestDependencyKey {
    public static var testValue: FeatureFlagClient = FeatureFlagClient(
        getString: unimplemented("\(Self.self).getString"),
        getBool: unimplemented("\(Self.self).getBool"),
        getNumber: unimplemented("\(Self.self).getNumber"),
        getDictionary: unimplemented("\(Self.self).getDictionary")
    )
}

public extension DependencyValues {
    var featureFlagClient: FeatureFlagClient {
        get { self[FeatureFlagClient.self] }
        set { self[FeatureFlagClient.self] = newValue }
    }
}
