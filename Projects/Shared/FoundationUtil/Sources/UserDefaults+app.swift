import ConstantUtil
import Foundation

public enum UserDefaultsKeys: String {
    case schoolType = "SCHOOL-TYPE"
    case orgCode = "ORG-CODE"
    case schoolCode = "SCHOOL-CODE"
    case school = "SCHOOL"
    case grade = "GRADE"
    case `class` = "CLASS"
    case major = "MAJOR"
    case isSkipWeekend = "IS-SKIP-WEEKEND"
    case isSkipAfterDinner = "IS-SKIP-AFTER-DINNER"
    case isOnModifiedTimeTable = "IS-ON-MODIFIED-TIME-TABLE"
    case widgetCount = "WIDGET-COUNT"
    case appOpenCount = "APP-OPEN-COUNT"
    case lastReviewRequestDate = "LAST-REVIEW-REQUEST-DATE"
    case hasReviewed = "HAS-REVIEWED"
}

public extension UserDefaults {
    static var app: UserDefaults {
        let group = AppGroup.group.rawValue
        return UserDefaults(suiteName: group) ?? .standard
    }
}
