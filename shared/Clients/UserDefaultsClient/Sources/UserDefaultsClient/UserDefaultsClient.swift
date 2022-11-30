import Foundation
import EnumUtil
import XCTestDynamicOverlay
import FoundationUtil
import Dependencies

public enum UserDefaultsKeys: String {
    case schoolType = "SCHOOL-TYPE"
    case orgCode = "ORG-CODE"
    case schoolCode = "SCHOOL-CODE"
    case school = "SCHOOL"
    case grade = "GRADE"
    case `class` = "CLASS"
    case major = "MAJOR"
    case isSkipWeekend = "IS-SKIP-WEEKEND"
}

public struct UserDefaultsClient {
    public let setValue: (UserDefaultsKeys, Any?) -> Void
}

extension UserDefaultsClient: DependencyKey {
    public static var liveValue: UserDefaultsClient = UserDefaultsClient(
        setValue: { key, value in
            if let value {
                UserDefaults.app.set(value, forKey: key.rawValue)
            } else {
                UserDefaults.app.removeObject(forKey: key.rawValue)
            }
        }
    )

    public func getValue<T: Codable>(key: UserDefaultsKeys, type: T.Type) -> T? {
        UserDefaults.app.value(forKey: key.rawValue) as? T
    }
}

extension UserDefaultsClient: TestDependencyKey {
    public static var testValue: UserDefaultsClient = UserDefaultsClient(
        setValue: { _, _ in }
    )
}

extension DependencyValues {
    public var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
