import Foundation

public enum AppGroup: String {
    #if os(iOS) || os(watchOS)
    case group = "group.baegteun.TodayWhat"
    #else
    case group = "235C2RVZ7L.TodayWhat"
    #endif

    public var containerURL: URL {
        switch self {
        case .group:
            return FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
        }
    }
}
