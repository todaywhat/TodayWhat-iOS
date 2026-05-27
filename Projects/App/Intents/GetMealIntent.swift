import AppIntents
import Entity
import Foundation
import MealClient
import SwiftUI
import TWLog

@available(iOS 16, macOS 13, *)
struct GetMealIntent: AppIntent {
  static let title: LocalizedStringResource = "급식 조회"
  static let description = IntentDescription("오늘 또는 내일의 급식 메뉴를 조회합니다")
  static let openAppWhenRun: Bool = false

  @Parameter(title: "날짜", default: .today)
  var daySelection: MealDaySelection

  @Parameter(title: "특정 날짜")
  var specifyDate: Date?

  @Parameter(title: "식사 시간", default: .all)
  var mealTime: MealTimeSelection

  static var parameterSummary: some ParameterSummary {
    When(\Self.$daySelection, .equalTo, .specify) {
      Summary("\(\.$daySelection) \(\.$mealTime) 급식 조회") {
        \.$specifyDate
      }
    } otherwise: {
      Summary("\(\.$daySelection) \(\.$mealTime) 급식 조회")
    }
  }

  init() {
    self.daySelection = .today
    self.mealTime = .all
  }

  init(
    mealTime: MealTimeSelection,
    daySelection: MealDaySelection = .today,
    specifyDate: Date? = nil
  ) {
    self.daySelection = daySelection
    self.mealTime = mealTime
    self.specifyDate = specifyDate
  }

  @MainActor
  func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView
    & ReturnsValue<MealResultEntity>
  {
    TWLog.enqueueEvent(DefaultEventLog(
      name: "meal_intent_performed",
      params: [
        "day_selection": daySelection.rawValue,
        "meal_time": mealTime.rawValue,
      ]
    ))

    let targetDate = daySelection == .specify ? (specifyDate ?? Date()) : daySelection.targetDate
    let meal = try await MealClient.liveValue.fetchMeal(targetDate)
    let response = formatMealResponse(
      meal: meal,
      timeSelection: mealTime,
      daySelection: daySelection
    )

    return .result(
      value: response.entity,
      dialog: IntentDialog(stringLiteral: response.dialog),
      view: MealIntentView(title: response.title, mealData: response.mealData)
    )
  }

  private func formatMealResponse(
    meal: Meal,
    timeSelection: MealTimeSelection,
    daySelection: MealDaySelection
  ) -> (dialog: String, title: String, entity: MealResultEntity, mealData: [MealData]) {
    let breakfast: [String]
    let lunch: [String]
    let dinner: [String]

    switch timeSelection {
    case .breakfast:
      breakfast = meal.breakfast.meals
      lunch = []
      dinner = []
    case .lunch:
      breakfast = []
      lunch = meal.lunch.meals
      dinner = []
    case .dinner:
      breakfast = []
      lunch = []
      dinner = meal.dinner.meals
    case .all:
      breakfast = meal.breakfast.meals
      lunch = meal.lunch.meals
      dinner = meal.dinner.meals
    }

    let entity = MealResultEntity(breakfast: breakfast, lunch: lunch, dinner: dinner)
    let mealData: [MealData]
    let dialog: String
    let title: String

    switch timeSelection {
    case .breakfast:
      mealData = [MealData(name: "아침", subMeal: meal.breakfast)]
      title = "\(daySelection.displayName) 아침"
      dialog = breakfast.isEmpty
        ? "\(daySelection.displayName) 아침 급식 정보가 없습니다"
        : "\(daySelection.displayName) 아침은 \(breakfast.joined(separator: ", "))입니다"
    case .lunch:
      mealData = [MealData(name: "점심", subMeal: meal.lunch)]
      title = "\(daySelection.displayName) 점심"
      dialog = lunch.isEmpty
        ? "\(daySelection.displayName) 점심 급식 정보가 없습니다"
        : "\(daySelection.displayName) 점심은 \(lunch.joined(separator: ", "))입니다"
    case .dinner:
      mealData = [MealData(name: "저녁", subMeal: meal.dinner)]
      title = "\(daySelection.displayName) 저녁"
      dialog = dinner.isEmpty
        ? "\(daySelection.displayName) 저녁 급식 정보가 없습니다"
        : "\(daySelection.displayName) 저녁은 \(dinner.joined(separator: ", "))입니다"
    case .all:
      mealData = [
        MealData(name: "아침", subMeal: meal.breakfast),
        MealData(name: "점심", subMeal: meal.lunch),
        MealData(name: "저녁", subMeal: meal.dinner),
      ]
      title = "\(daySelection.displayName) 급식"
      dialog = meal.isEmpty
        ? "\(daySelection.displayName) 급식 정보가 없습니다"
        : "\(daySelection.displayName) 급식을 조회했습니다"
    }

    return (dialog: dialog, title: title, entity: entity, mealData: mealData)
  }
}

@available(iOS 16, macOS 13, *)
enum MealDaySelection: String, AppEnum {
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

  static let caseDisplayRepresentations: [MealDaySelection: DisplayRepresentation] = [
    .yesterday: "어제",
    .today: "오늘",
    .tomorrow: "내일",
    .specify: "날짜 선택",
  ]
}

@available(iOS 16, macOS 13, *)
enum MealTimeSelection: String, AppEnum {
  case breakfast
  case lunch
  case dinner
  case all

  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "식사 시간")

  static let caseDisplayRepresentations: [MealTimeSelection: DisplayRepresentation] = [
    .breakfast: "아침",
    .lunch: "점심",
    .dinner: "저녁",
    .all: "전체",
  ]
}

struct MealData {
  let name: String
  let subMeal: Meal.SubMeal
}

@available(iOS 16, macOS 13, *)
struct MealResultEntity: AppEntity {
  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "급식 결과")
  static let defaultQuery = MealResultEntityQuery()

  var id: String
  @Property(title: "아침")
  var breakfast: [String]
  @Property(title: "점심")
  var lunch: [String]
  @Property(title: "저녁")
  var dinner: [String]

  var displayRepresentation: DisplayRepresentation {
    let parts = [
      breakfast.isEmpty ? nil : "[아침] \(breakfast.joined(separator: ", "))",
      lunch.isEmpty ? nil : "[점심] \(lunch.joined(separator: ", "))",
      dinner.isEmpty ? nil : "[저녁] \(dinner.joined(separator: ", "))",
    ].compactMap { $0 }
    return DisplayRepresentation(title: "\(parts.joined(separator: "\n\n"))")
  }

  init(id: String = UUID().uuidString, breakfast: [String], lunch: [String], dinner: [String]) {
    self.id = id
    self.breakfast = breakfast
    self.lunch = lunch
    self.dinner = dinner
  }
}

@available(iOS 16, macOS 13, *)
struct MealResultEntityQuery: EntityQuery {
  func entities(for identifiers: [String]) async throws -> [MealResultEntity] {
    []
  }
}

@available(iOS 16, macOS 13, *)
struct MealIntentView: View {
  let title: String
  let mealData: [MealData]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)

      if mealData.isEmpty || mealData.allSatisfy({ $0.subMeal.meals.isEmpty }) {
        Text("급식 정보가 없습니다")
          .font(.subheadline)
          .foregroundColor(.secondary)
      } else {
        ForEach(Array(mealData.enumerated()), id: \.offset) { _, data in
          if !data.subMeal.meals.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
              HStack {
                Text(data.name)
                  .font(.subheadline)
                  .fontWeight(.semibold)
                Spacer()
                Text("\(Int(data.subMeal.cal.rounded())) kcal")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }

              ForEach(data.subMeal.meals, id: \.self) { menu in
                Text("• \(menu)")
                  .font(.caption)
              }
            }
          }
        }
      }
    }
    .padding()
  }
}
