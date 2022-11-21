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
}

public struct UserDefaultsClient {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsClient: DependencyKey {
    public static var liveValue: UserDefaultsClient = UserDefaultsClient(userDefaults: .app)

    public var schoolType: SchoolType? {
        get { SchoolType(rawValue: userDefaults.string(forKey: UserDefaultsKeys.schoolType.rawValue) ?? "") }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.schoolType.rawValue) }
    }
    public var orgCode: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.orgCode.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.orgCode.rawValue) }
    }
    public var schoolCode: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.schoolCode.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.schoolCode.rawValue) }
    }
    public var school: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.school.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.school.rawValue) }
    }
    public var grade: Int {
        get { userDefaults.integer(forKey: UserDefaultsKeys.grade.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.grade.rawValue) }
    }
    public var `class`: Int {
        get { userDefaults.integer(forKey: UserDefaultsKeys.class.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.class.rawValue) }
    }
    public var major: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.major.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.major.rawValue) }
    }
}

extension UserDefaultsClient: TestDependencyKey {
    public static var testValue: UserDefaultsClient = UserDefaultsClient(userDefaults: .init())
}

extension DependencyValues {
    public var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
