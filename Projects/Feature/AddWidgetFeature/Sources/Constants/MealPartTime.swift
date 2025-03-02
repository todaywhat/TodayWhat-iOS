enum MealPartTime: Int, CaseIterable {
    case breakfast
    case lunch
    case dinner

    var display: String {
        switch self {
        case .breakfast:
            return "아침"

        case .lunch:
            return "점심"

        case .dinner:
            return "저녁"
        }
    }
}
