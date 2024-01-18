import Foundation
import EnumUtil
import XCTestDynamicOverlay
import FoundationUtil
import Dependencies

public typealias UserDefaultsKeys = FoundationUtil.UserDefaultsKeys

public struct UserDefaultsClient {
    public let setValue: (UserDefaultsKeys, Any?) -> Void
    public let getValue: (UserDefaultsKeys) -> Any?
}

extension UserDefaultsClient: DependencyKey {
    public static var liveValue: UserDefaultsClient = UserDefaultsClient(
        setValue: { key, value in
            @Dependency(\.userDefaults) var userDefaults
            if let value {
                userDefaults.set(value, forKey: key.rawValue)
            } else {
                userDefaults.removeObject(forKey: key.rawValue)
            }
        },
        getValue: { key in
            @Dependency(\.userDefaults) var userDefaults
            return userDefaults.value(forKey: key.rawValue)
        }
    )
}

extension UserDefaultsClient: TestDependencyKey {
    public static var testValue: UserDefaultsClient = UserDefaultsClient(
        setValue: { _, _ in },
        getValue: { _ in "" }
    )
}

extension DependencyValues {
    public var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

extension UserDefaults: DependencyKey {
    public static var liveValue: UserDefaults = UserDefaults.app
}

extension UserDefaults: @unchecked Sendable {}

extension DependencyValues {
    public var userDefaults: UserDefaults {
        get { self[UserDefaults.self] }
        set { self[UserDefaults.self] = newValue }
    }
}
