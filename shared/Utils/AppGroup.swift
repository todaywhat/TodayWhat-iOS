import Foundation

enum AppGroup: String {
    case group = "group.baegteun.TodayWhat"

    public var containerURL: URL {
        switch self {
        case .group:
            return FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
        }
    }
}
