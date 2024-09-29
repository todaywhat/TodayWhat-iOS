import DesignSystem
import Entity
import SwiftUI
import WidgetKit

struct MealTimeTableWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    let entry: MealTimeTableProvider.Entry

    public init(entry: MealTimeTableProvider.Entry) {
        self.entry = entry
    }

    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            widgetBody()
                .containerBackground(for: .widget) {
                    Color.backgroundMain
                }
        } else {
            widgetBody()
        }
    }

    @ViewBuilder
    private func widgetBody() -> some View {
        switch widgetFamily {
        case .systemMedium:
            MediumMealTimeTableWidgetView(entry: entry)
        default:
            EmptyView()
        }
    }
}

private struct MediumMealTimeTableWidgetView: View {
    let entry: MealTimeTableProvider.Entry
    private let fiveRows = Array(repeating: GridItem(.flexible(), spacing: nil), count: 5)
    private var calorie: CGFloat {
        CGFloat(entry.meal.meals(mealPartTime: entry.mealPartTime).cal)
    }

    var body: some View {
        HStack(spacing: 8) {
            timetableView()
            mealView()
        }
        .padding(8)
    }

    @ViewBuilder
    private func timetableView() -> some View {
        GeometryReader { proxy in
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(getTimeTableText(date: entry.date))
                        .twFont(.headline4, color: .textPrimary)

                    Spacer()
                }

                LazyHGrid(rows: fiveRows, spacing: 0) {
                    ForEach(entry.timetables, id: \.hashValue) { timetable in
                        HStack(spacing: 2) {
                            Text("\(timetable.perio)")
                                .twFont(.caption1, color: .textSecondary)

                            Text(timetable.content)
                                .twFont(.caption1, color: .extraBlack)

                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                        .frame(width: (proxy.size.width / 2) - 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(8)
            .background {
                Color.cardBackground
                    .cornerRadius(8)
            }
        }
    }

    private func mealView() -> some View {
        GeometryReader { proxy in
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(getMealText(date: entry.date))
                        .twFont(.headline4, color: .extraBlack)

                    Spacer()
                }

                LazyHGrid(rows: fiveRows, spacing: 0) {
                    ForEach(entry.meal.meals(mealPartTime: entry.mealPartTime).meals, id: \.hashValue) { meal in
                        HStack(spacing: 0) {
                            Text(mealDisplay(meal: meal))
                                .frame(maxHeight: .infinity)
                                .twFont(.caption1)
                                .foregroundColor(isMealContainsAllergy(meal: meal) ? .red : .extraBlack)

                            Spacer()
                        }
                        .frame(width: (proxy.size.width / 2) - 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(8)
            .background {
                Color.cardBackground
                    .cornerRadius(8)
            }
        }
    }

    func getTimeTableText(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDate(date, inSameDayAs: now) {
            return "오늘의 [시간표]"
        }

        let components = calendar.dateComponents([.day], from: now, to: date)

        if let days = components.day, days == 1 {
            return "내일의 [시간표]"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date)
        return "\(dayOfWeek) [시간표]"
    }

    func getMealText(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDate(date, inSameDayAs: now) {
            return "오늘의 [\(entry.mealPartTime.display)]"
        }

        let components = calendar.dateComponents([.day], from: now, to: date)

        if let days = components.day, days == 1 {
            return "내일의 [\(entry.mealPartTime.display)]"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date)
        return "\(dayOfWeek) [\(entry.mealPartTime.display)]"
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }

    private func isMealContainsAllergy(meal: String) -> Bool {
        entry.allergyList
            .first { meal.contains("(\($0.number)") || meal.contains(".\($0.number)") } != nil
    }
}

private extension Meal {
    func meals(mealPartTime: MealPartTime) -> Meal.SubMeal {
        switch mealPartTime {
        case .breakfast:
            return breakfast

        case .lunch:
            return lunch

        case .dinner:
            return dinner
        }
    }
}
