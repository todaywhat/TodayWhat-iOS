enum SchoolKind: String, Decodable {
    case elementary = "초등학교"
    case middle = "중학교"
    case high = "고등학교"
    case special = "외국인학교"
    
    func toType() -> SchoolType {
        switch self {
        case .elementary:
            return .elementary
        case .middle:
            return .middle
        case .high:
            return .high
        case .special:
            return .special
        }
    }
}
