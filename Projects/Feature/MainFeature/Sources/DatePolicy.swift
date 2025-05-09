import Foundation

public struct DatePolicy: Sendable {
    private let isSkipWeekend: Bool
    private let isSkipAfterDinner: Bool

    public init(isSkipWeekend: Bool, isSkipAfterDinner: Bool) {
        self.isSkipWeekend = isSkipWeekend
        self.isSkipAfterDinner = isSkipAfterDinner
    }

    public func displayText(for date: Date, baseDate: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: baseDate) {
            return "오늘"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: baseDate),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "어제"
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: baseDate),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "내일"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    public func adjustedDate(for date: Date) -> Date {
        var adjustedDate = date

        // 저녁 7시 이후 다음날 표시가 활성화된 경우
        if isSkipAfterDinner, adjustedDate.hour >= 19 {
            adjustedDate = adjustedDate.adding(by: .day, value: 1)
        }

        // 주말 건너뛰기가 활성화된 경우
        if isSkipWeekend {
            if adjustedDate.weekday == 7 { // 토요일
                adjustedDate = adjustedDate.adding(by: .day, value: 2)
            } else if adjustedDate.weekday == 1 { // 일요일
                adjustedDate = adjustedDate.adding(by: .day, value: 1)
            }
        }

        return adjustedDate
    }

    public func previousDay(from date: Date) -> Date {
        var previousDate = date.adding(by: .day, value: -1)

        if isSkipWeekend {
            if previousDate.weekday == 7 { // 토요일
                previousDate = previousDate.adding(by: .day, value: -1)
            } else if previousDate.weekday == 1 { // 일요일
                previousDate = previousDate.adding(by: .day, value: -2)
            }
        }

        return previousDate
    }

    public func nextDay(from date: Date) -> Date {
        var nextDate = date.adding(by: .day, value: 1)

        if isSkipWeekend {
            if nextDate.weekday == 7 { // 토요일
                nextDate = nextDate.adding(by: .day, value: 2)
            } else if nextDate.weekday == 1 { // 일요일
                nextDate = nextDate.adding(by: .day, value: 1)
            }
        }

        return nextDate
    }
}
