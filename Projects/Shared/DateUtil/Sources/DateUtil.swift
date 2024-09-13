import Foundation

public extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }

    /// 1 2 3 4 5 6 7 - 일 월 화 수 목 금 토
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }

    var weekdayString: String {
        switch weekday {
        case 1: return "일요일"
        case 2: return "월요일"
        case 3: return "화요일"
        case 4: return "수요일"
        case 5: return "목요일"
        case 6: return "금요일"
        case 7: return "토요일"
        default: return ""
        }
    }

    var shortWeekdayString: String {
        switch weekday {
        case 1: return "일"
        case 2: return "월"
        case 3: return "화"
        case 4: return "수"
        case 5: return "목"
        case 6: return "금"
        case 7: return "토"
        default: return ""
        }
    }

    func adding(by component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }

    static func getDateForDayOfWeek(dayOfWeek: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        let daysUntilTargetDay = (dayOfWeek - calendar.component(.weekday, from: today) + 7) % 7
        let targetDate = calendar.date(byAdding: .day, value: daysUntilTargetDay, to: today)
        return targetDate
    }

    func toStringCustomFormat(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

public extension String {
    func toDateCustomFormat(format: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self) ?? .init()
    }
}
