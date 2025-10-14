import ComposableArchitecture
import Entity
import EnumUtil
import Foundation
import LocalDatabaseClient
import Sharing
import TimeTableClient
import UserDefaultsClient

public struct WeeklyTimeTableCore: Reducer {
    private enum CancellableID: Hashable {
        case fetch
    }

    public init() {}

    public struct State: Equatable {
        public var weeklyTimeTable: WeeklyTimeTable? = nil
        public var isLoading = false
        public var showWeekend = false
        @Shared public var displayDate: Date

        public init(displayDate: Shared<Date>) {
            self._displayDate = displayDate
        }
    }

    public struct WeeklyTimeTable: Equatable {
        public let weekdays: [String]
        public let dates: [String]
        public let periods: [Int]
        public let subjects: [[String]]
        public let todayIndex: Int?

        public init(
            weekdays: [String],
            dates: [String],
            periods: [Int],
            subjects: [[String]],
            todayIndex: Int? = nil
        ) {
            self.weekdays = weekdays
            self.dates = dates
            self.periods = periods
            self.subjects = subjects
            self.todayIndex = todayIndex
        }

        public func subject(for period: Int, weekday: Int) -> String {
            guard weekday < subjects.count,
                  period < subjects[weekday].count
            else {
                return ""
            }
            return subjects[weekday][period]
        }

        public func isToday(weekdayIndex: Int) -> Bool {
            return todayIndex == weekdayIndex
        }

        public func actualPeriodCount(for weekdayIndex: Int) -> Int {
            guard weekdayIndex < subjects.count else { return 0 }
            let daySubjects = subjects[weekdayIndex]
            for i in (0..<daySubjects.count).reversed() {
                if !daySubjects[i].isEmpty {
                    return i + 1
                }
            }
            return 0
        }
    }

    public enum Action: Equatable {
        case onLoad
        case onAppear
        case refresh
        case refreshData
        case timeTableResponse(TaskResult<WeeklyTimeTable>)
    }

    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    public var body: some ReducerOf<WeeklyTimeTableCore> {
        Reduce { state, action in
            switch action {
            case .onLoad:
                return .merge(
                    .send(.onAppear),
                    .publisher {
                        state.$displayDate.publisher
                            .map { _ in Action.refreshData }
                    }
                )

            case .onAppear, .refreshData:
                state.isLoading = true
                state.showWeekend =
                    !(userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false)

                let calendar = Calendar.current
                let baseDate = state.displayDate
                let normalizedBaseDate = calendar.startOfDay(for: baseDate)
                let weekday = calendar.component(.weekday, from: normalizedBaseDate)
                let daysFromMonday = (weekday + 5) % 7
                let mondayDate =
                    calendar.date(byAdding: .day, value: -daysFromMonday, to: normalizedBaseDate)
                        ?? normalizedBaseDate

                return .concatenate(
                    .cancel(id: CancellableID.fetch),
                    .run { [mondayDate, showWeekend = state.showWeekend] send in
                        do {
                            let weeklyData = try await fetchWeeklyTimeTable(
                                mondayDate: mondayDate,
                                showWeekend: showWeekend
                            )
                            await send(
                                Action.timeTableResponse(TaskResult.success(weeklyData))
                            )
                        } catch {
                            await send(Action.timeTableResponse(TaskResult.failure(error)))
                        }
                    }
                    .cancellable(id: CancellableID.fetch)
                )

            case let .timeTableResponse(.success(weeklyTimeTable)):
                state.isLoading = false
                state.weeklyTimeTable = weeklyTimeTable

            case .timeTableResponse(.failure(_)):
                state.weeklyTimeTable = nil
                state.isLoading = false

            default:
                return .none
            }
            return .none
        }
    }

    private func fetchWeeklyTimeTable(mondayDate: Date, showWeekend: Bool) async throws -> WeeklyTimeTable {
        let calendar = Calendar.current
        let dayCount = showWeekend ? 7 : 5
        var weeklyData: [Int: [TimeTable]] = [:]
        let isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
        let endDate = calendar.date(byAdding: .day, value: dayCount - 1, to: mondayDate) ?? mondayDate
        do {
            let fetchedTimeTables = try await timeTableClient.fetchTimeTableRange(mondayDate, endDate)
            let groupedByDate = Dictionary(
                grouping: fetchedTimeTables,
                by: { table -> Date in
                    let targetDate = table.date ?? mondayDate
                    return calendar.startOfDay(for: targetDate)
                }
            )

            let modifiedRecords = try? localDatabaseClient.readRecords(as: ModifiedTimeTableLocalEntity.self)

            for i in 0..<dayCount {
                let currentDate = calendar.date(byAdding: .day, value: i, to: mondayDate) ?? mondayDate
                let normalizedDate = calendar.startOfDay(for: currentDate)
                let dayData = groupedByDate[normalizedDate] ?? []
                
                if isOnModifiedTimeTable {
                    let currentDate = calendar.date(byAdding: .day, value: i, to: mondayDate) ?? mondayDate
                    let weekday = calendar.component(.weekday, from: currentDate)
                    let customDayRecords = modifiedRecords?
                        .filter { $0.weekday == weekday }
                        .sorted { $0.perio < $1.perio }
                        .map { TimeTable(perio: $0.perio, content: $0.content) }
                    
                    weeklyData[i] = customDayRecords ?? dayData.sorted { $0.perio < $1.perio }
                } else {
                    weeklyData[i] = dayData.sorted { $0.perio < $1.perio }
                }
            }
        } catch {
            for i in 0..<dayCount {
                weeklyData[i] = []
            }
        }

        return createWeeklyTableFromAPIData(
            weeklyData: weeklyData,
            mondayDate: mondayDate,
            showWeekend: showWeekend
        )
    }

    // swiftlint: disable cyclomatic_complexity
    private func createWeeklyTableFromAPIData(
        weeklyData: [Int: [TimeTable]],
        mondayDate: Date,
        showWeekend: Bool
    ) -> WeeklyTimeTable {
        let calendar = Calendar.current
        let weekdays =
            showWeekend
                ? ["월", "화", "수", "목", "금", "토", "일"] : ["월", "화", "수", "목", "금"]
        var dates: [String] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"

        let dayCount = showWeekend ? 7 : 5
        for i in 0..<dayCount {
            let currentDate =
                calendar.date(byAdding: .day, value: i, to: mondayDate) ?? mondayDate
            dates.append(dateFormatter.string(from: currentDate))
        }

        var weeklySubjects: [[String]] = Array(repeating: [], count: dayCount)
        var maxPeriods = 0

        for i in 0..<dayCount {
            let dayTimeTable = weeklyData[i] ?? []
            let sortedDayTimeTable = dayTimeTable.sorted { $0.perio < $1.perio }

            var daySubjects: [String] = []
            var lastPeriod = 0

            for timeTable in sortedDayTimeTable {
                while lastPeriod + 1 < timeTable.perio {
                    daySubjects.append("")
                    lastPeriod += 1
                }
                daySubjects.append(sanitizeSubject(timeTable.content))
                lastPeriod = timeTable.perio
            }

            weeklySubjects[i] = daySubjects
            maxPeriods = max(maxPeriods, daySubjects.count)
        }

        for i in 0..<dayCount {
            while weeklySubjects[i].count < maxPeriods {
                weeklySubjects[i].append("")
            }
        }

        let periods = maxPeriods > 0 ? Array(1...maxPeriods) : []

        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        let todayIndex: Int?

        if showWeekend {
            switch todayWeekday {
            case 2: todayIndex = 0 // 월요일
            case 3: todayIndex = 1 // 화요일
            case 4: todayIndex = 2 // 수요일
            case 5: todayIndex = 3 // 목요일
            case 6: todayIndex = 4 // 금요일
            case 7: todayIndex = 5 // 토요일
            case 1: todayIndex = 6 // 일요일
            default: todayIndex = nil
            }
        } else {
            switch todayWeekday {
            case 2: todayIndex = 0 // 월요일
            case 3: todayIndex = 1 // 화요일
            case 4: todayIndex = 2 // 수요일
            case 5: todayIndex = 3 // 목요일
            case 6: todayIndex = 4 // 금요일
            default: todayIndex = nil
            }
        }

        return WeeklyTimeTable(
            weekdays: weekdays,
            dates: dates,
            periods: periods,
            subjects: weeklySubjects,
            todayIndex: todayIndex
        )
    }

    private func sanitizeSubject(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.replacingOccurrences(
            of: #"^\*+\s*"#,
            with: "",
            options: [.regularExpression]
        )
    }
}
