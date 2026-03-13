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
    @Environment(\.backportedWidgetRenderingMode) var widgetRenderingMode: BackportedWidgetRenderingMode

    @ViewBuilder
    private var columnBackground: some View {
        switch widgetRenderingMode {
        case .accented:
            if #available(iOSApplicationExtension 26.0, *) {
                EmptyView()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.cardBackground, lineWidth: 1)
            }
                
            
        case .fullColor, .vibrant:
            if #available(iOSApplicationExtension 26.0, *) {
                ConcentricRectangle()
                    .fill(Color.cardBackground)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            }

        default:
            if #available(iOSApplicationExtension 26.0, *) {
                ConcentricRectangle()
                    .fill(Color.cardBackground)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
            }
        }
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
                    Text(getTimeTableText(date: entry.timeTableDate))
                        .twFont(.headline4, color: .textPrimary)

                    Spacer()
                }

                if entry.timetables.isEmpty {
                    VStack(spacing: 4) {
                        Text("시간표를 찾을 수 없어요!")
                            .twFont(.caption1, color: .textSecondary)

                        if Date().month == 3 || Date().month == 9 {
                            Text("학기 초에는 neis에\n정규시간표가 등록되어있지\n않을 수도 있어요.")
                                .multilineTextAlignment(.center)
                                .twFont(.caption1, color: .textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
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
                    .widgetAccentableIfAvailable()
                }
            }
            .padding(8)
            .background {
                columnBackground
            }
        }
    }

    private func mealView() -> some View {
        GeometryReader { proxy in
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(getMealText(date: entry.mealDate))
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
            .widgetAccentableIfAvailable()
            .padding(8)
            .background {
                columnBackground
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
