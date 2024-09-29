import Dependencies
import Entity
import EnumUtil
import Foundation
import SwiftUI
import TimeTableClient
import WidgetKit

struct TimeTableProvider: TimelineProvider {
    typealias Entry = TimeTableEntry

    @Dependency(\.timeTableClient) var timeTableClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient

    func placeholder(in context: Context) -> TimeTableEntry {
        .empty()
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (TimeTableEntry) -> Void
    ) {
        Task {
            var currentDate = Date()
            if currentDate.hour >= 20 {
                currentDate = currentDate.adding(by: .day, value: 1)
            }
            do {
                let timeTable = try await timeTableClient.fetchTimeTable(currentDate).prefix(7)
                let entry = TimeTableEntry(date: currentDate, timeTable: Array(timeTable))
                completion(entry)
            } catch {
                let entry = TimeTableEntry.empty()
                completion(entry)
            }
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<TimeTableEntry>) -> Void
    ) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? .init()
        Task {
            var currentDate = Date()
            if currentDate.hour >= 20 {
                currentDate = currentDate.adding(by: .hour, value: 5)
            }
            do {
                let timeTable = try await fetchTimeTables(date: currentDate)
                let entry = TimeTableEntry(date: currentDate, timeTable: Array(timeTable))
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                let entry = TimeTableEntry.empty()
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }

    private func fetchTimeTables(date: Date) async throws -> [TimeTable] {
        let isOnModifiedTimeTable = userDefaultsClient.getValue(.isOnModifiedTimeTable) as? Bool ?? false
        if isOnModifiedTimeTable {
            let modifiedTimeTables: [ModifiedTimeTableLocalEntity]? = try? localDatabaseClient
                .readRecords(as: ModifiedTimeTableLocalEntity.self)
                .filter { $0.weekday == WeekdayType(weekday: date.weekday).rawValue }
            return (modifiedTimeTables ?? [])
                .sorted { $0.perio < $1.perio }
                .map { TimeTable(perio: $0.perio, content: $0.content) }
        }
        let timeTable = try await timeTableClient.fetchTimeTable(date).prefix(7)
        return Array(timeTable)
    }
}

struct TimeTableEntry: TimelineEntry {
    let date: Date
    let timeTable: [TimeTable]

    static func empty() -> TimeTableEntry {
        TimeTableEntry(
            date: Date(),
            timeTable: []
        )
    }
}

struct TodayWhatTimeTableWidget: Widget {
    let kind: String = "TodayWhatTimeTableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TimeTableProvider()
        ) { entry in
            TimeTableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 시간표 뭐임")
        .description("오늘 시간표를 확인해요!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
