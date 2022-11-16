import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

enum UserDefaultsKeys: String {
    case schoolType = "SCHOOL-TYPE"
    case orgCode = "ORG-CODE"
    case schoolCode = "SCHOOL-CODE"
    case school = "SCHOOL"
    case grade = "GRADE"
    case `class` = "CLASS"
    case major = "MAJOR"
}

struct UserDefaultsClient {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsClient: DependencyKey {
    static var liveValue: UserDefaultsClient = UserDefaultsClient(userDefaults: .app)

    var schoolType: SchoolType? {
        get { SchoolType(rawValue: userDefaults.string(forKey: UserDefaultsKeys.schoolType.rawValue) ?? "") }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.schoolType.rawValue) }
    }
    var orgCode: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.orgCode.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.orgCode.rawValue) }
    }
    var schoolCode: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.schoolCode.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.schoolCode.rawValue) }
    }
    var school: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.school.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.school.rawValue) }
    }
    var grade: Int {
        get { userDefaults.integer(forKey: UserDefaultsKeys.grade.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.grade.rawValue) }
    }
    var `class`: Int {
        get { userDefaults.integer(forKey: UserDefaultsKeys.class.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.class.rawValue) }
    }
    var major: String? {
        get { userDefaults.string(forKey: UserDefaultsKeys.major.rawValue) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.major.rawValue) }
    }
}

extension UserDefaultsClient: TestDependencyKey {
    static var testValue: UserDefaultsClient = UserDefaultsClient(userDefaults: .init())
}

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
