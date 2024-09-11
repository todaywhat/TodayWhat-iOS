public enum SchoolType: String, Decodable {
    case elementary
    case middle
    case high
    case special
}

public extension SchoolType {
    func toSubURL() -> String {
        switch self {
        case .elementary:
            return "elsTimetable"
        case .middle:
            return "misTimetable"
        case .high:
            return "hisTimetable"
        case .special:
            return "spsTimetable"
        }
    }

    var analyticsValue: String {
        switch self {
        case .elementary:
            return "elementary"
        case .middle:
            return "middle"
        case .high:
            return "high"
        case .special:
            return "special"
        }
    }
}
