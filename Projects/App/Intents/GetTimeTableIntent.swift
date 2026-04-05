import AppIntents
import Entity
import Foundation
import SwiftUI
import TimeTableClient
import TWLog

@available(iOS 16, macOS 13, *)
struct GetTimeTableIntent: AppIntent {
  static let title: LocalizedStringResource = "시간표 조회"
  static let description = IntentDescription("오늘 또는 내일의 시간표를 조회합니다")
  static let openAppWhenRun: Bool = false

  @Parameter(title: "날짜", default: .today)
  var daySelection: TimeTableDaySelection

  @Parameter(title: "특정 날짜")
  var specifyDate: Date?

  static var parameterSummary: some ParameterSummary {
    When(\Self.$daySelection, .equalTo, .specify) {
      Summary("\(\.$daySelection) 시간표 조회") {
        \.$specifyDate
      }
    } otherwise: {
      Summary("\(\.$daySelection) 시간표 조회")
    }
  }

  init() {
    self.daySelection = .today
  }

  init(daySelection: TimeTableDaySelection = .today, specifyDate: Date? = nil) {
    self.daySelection = daySelection
    self.specifyDate = specifyDate
  }

  @MainActor
  func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView
    & ReturnsValue<[TimeTableResultEntity]>
  {
    TWLog.enqueueEvent(DefaultEventLog(
      name: "timetable_intent_performed",
      params: ["day_selection": daySelection.rawValue]
    ))

    let targetDate = daySelection == .specify ? (specifyDate ?? Date()) : daySelection.targetDate
    let timeTables = try await TimeTableClient.liveValue.fetchTimeTable(targetDate)
    let sortedTimeTables = timeTables.sorted { $0.perio < $1.perio }
    let dialog = formatDialogText(timeTables: sortedTimeTables)
    let value = sortedTimeTables.map {
      TimeTableResultEntity(period: $0.perio, subject: $0.content)
    }

    return .result(
      value: value,
      dialog: IntentDialog(stringLiteral: dialog),
      view: TimeTableIntentView(
        title: "\(daySelection.displayName) 시간표",
        timeTables: sortedTimeTables
      )
    )
  }

  private func formatDialogText(timeTables: [TimeTable]) -> String {
    guard !timeTables.isEmpty else {
      return "\(daySelection.displayName) 시간표 정보가 없습니다"
    }

    let summary = timeTables.map { "\($0.perio)교시 \($0.content)" }.joined(separator: ", ")
    return "\(daySelection.displayName) 시간표는 \(summary)입니다"
  }
}

@available(iOS 16, macOS 13, *)
enum TimeTableDaySelection: String, AppEnum {
  case yesterday
  case today
  case tomorrow
  case specify

  var displayName: String {
    switch self {
    case .yesterday: return "어제"
    case .today: return "오늘"
    case .tomorrow: return "내일"
    case .specify: return "날짜 선택"
    }
  }

  var targetDate: Date {
    switch self {
    case .yesterday:
      return Calendar.autoupdatingCurrent.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    case .today:
      return Date()
    case .tomorrow:
      return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    case .specify:
      return Date()
    }
  }

  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "날짜")

  static let caseDisplayRepresentations: [TimeTableDaySelection: DisplayRepresentation] = [
    .yesterday: "어제",
    .today: "오늘",
    .tomorrow: "내일",
    .specify: "날짜 선택",
  ]
}

@available(iOS 16, macOS 13, *)
struct TimeTableResultEntity: AppEntity {
  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "시간표")
  static let defaultQuery = TimeTableResultEntityQuery()

  var id: String
  @Property(title: "교시")
  var period: Int
  @Property(title: "과목")
  var subject: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(period)교시 \(subject)")
  }

  init(period: Int, subject: String) {
    self.id = "\(period)-\(subject)"
    self.period = period
    self.subject = subject
  }
}

@available(iOS 16, macOS 13, *)
struct TimeTableResultEntityQuery: EntityQuery {
  func entities(for identifiers: [String]) async throws -> [TimeTableResultEntity] {
    []
  }
}

@available(iOS 16, macOS 13, *)
struct TimeTableIntentView: View {
  let title: String
  let timeTables: [TimeTable]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)

      if timeTables.isEmpty {
        Text("시간표 정보가 없습니다")
          .font(.subheadline)
          .foregroundColor(.secondary)
      } else {
        ForEach(timeTables, id: \.self) { timeTable in
          HStack(spacing: 10) {
            Text("\(timeTable.perio)")
              .font(.caption)
              .fontWeight(.bold)
              .frame(width: 24, height: 24)
              .clipShape(Circle())

            Text(timeTable.content)
              .font(.subheadline)

            Spacer()
          }
        }
      }
    }
    .padding()
  }
}
