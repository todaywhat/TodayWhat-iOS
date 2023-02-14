import ConstantUtil
import Foundation

public extension UserDefaults {
    static var app: UserDefaults {
        let group = AppGroup.group.rawValue
        return UserDefaults(suiteName: group) ?? .standard
    }
}
