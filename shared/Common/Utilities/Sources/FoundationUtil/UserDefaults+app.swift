import Foundation

public extension UserDefaults {
    static var app: UserDefaults {
        let group = "group.baegteun.TodayWhat"
        return UserDefaults(suiteName: group) ?? .standard
    }
}
