import ConstantUtil
import Foundation

public extension UserDefaults {
    static var app: UserDefaults {
        let group = AppGroup.group.rawValue
        print(group)
        return UserDefaults(suiteName: group) ?? .standard
    }
}
