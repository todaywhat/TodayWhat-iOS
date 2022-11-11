enum SchoolType: String, Decodable {
    case elementary
    case middle
    case high
    case special
}

extension SchoolType {
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
}
