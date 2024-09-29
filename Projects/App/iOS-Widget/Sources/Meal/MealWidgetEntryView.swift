import Dependencies
import DesignSystem
import Entity
import Intents
import SwiftUI
import SwiftUIUtil
import WidgetKit

struct MealWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    let entry: MealProvider.Entry

    public init(entry: MealProvider.Entry) {
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
        case .systemSmall:
            SmallMealWidgetView(entry: entry)

        case .systemMedium:
            MediumMealWidgetView(entry: entry)

        case .systemLarge:
            LargeMealWidgetView(entry: entry)

        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)

        case .accessoryCircular:
            CircularWidgetView()

        default:
            EmptyView()
        }
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

private struct SmallMealWidgetView: View {
    var entry: MealProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("[\(entry.mealPartTime.display)]")
                .frame(maxHeight: .infinity)
                .twFont(.caption1, color: .textSecondary)

            ForEach(entry.meal.meals(mealPartTime: entry.mealPartTime).meals, id: \.hashValue) { meal in
                HStack {
                    Text(mealDisplay(meal: meal))
                        .frame(maxHeight: .infinity)
                        .twFont(.caption1)
                        .foregroundColor(isMealContainsAllergy(meal: meal) ? .red : .textPrimary)

                    Spacer()
                }
            }
        }
        .padding(12)
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }

    private func isMealContainsAllergy(meal: String) -> Bool {
        entry.allergyList
            .first { meal.contains("(\($0.number)") || meal.contains(".\($0.number)") } != nil
    }
}

private struct MediumMealWidgetView: View {
    var entry: MealProvider.Entry
    private let rows = Array(repeating: GridItem(.flexible(), spacing: nil), count: 4)
    private var calorie: CGFloat {
        CGFloat(entry.meal.meals(mealPartTime: entry.mealPartTime).cal)
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("ONMI")
                        .font(.custom("Fraunces9pt-Black", size: 16))
                        .foregroundColor(.extraBlack)

                    Text("[\(entry.mealPartTime.display)]")
                        .twFont(.caption1, color: .extraBlack)

                    Spacer()

                    Text("\(String(format: "%.1f", calorie)) kcal")
                        .twFont(.caption1, color: .textSecondary)
                }
                .padding(.horizontal, 4)

                LazyHGrid(rows: rows, spacing: 0) {
                    ForEach(entry.meal.meals(mealPartTime: entry.mealPartTime).meals, id: \.hashValue) { meal in
                        HStack(spacing: 0) {
                            Text(mealDisplay(meal: meal))
                                .frame(maxHeight: .infinity)
                                .twFont(.caption1)
                                .foregroundColor(isMealContainsAllergy(meal: meal) ? .red : .extraBlack)

                            Spacer()
                        }
                        .frame(width: (proxy.size.width / 2) - 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(8)
                .background {
                    Color.cardBackground
                        .cornerRadius(8)
                }
                .padding([.bottom, .horizontal], 4)
            }
            .padding(12)
        }
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }

    private func isMealContainsAllergy(meal: String) -> Bool {
        entry.allergyList
            .first { meal.contains("(\($0.number)") || meal.contains(".\($0.number)") } != nil
    }
}

private struct LargeMealWidgetView: View {
    var entry: MealProvider.Entry
    private var calorie: CGFloat {
        CGFloat(entry.meal.meals(mealPartTime: entry.mealPartTime).cal)
    }

    var body: some View {
        VStack(spacing: 4) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("ONMI")
                        .font(.custom("Fraunces9pt-Black", size: 16))
                        .foregroundColor(.extraBlack)

                    Text("[\(entry.mealPartTime.display)]")
                        .twFont(.caption1, color: .extraBlack)

                    Spacer()

                    Text("\(String(format: "%.1f", calorie)) Kcal")
                        .twFont(.caption1, color: .textSecondary)
                }

                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.cardBackground)
                        .frame(height: 8)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.textPrimary)
                                .frame(width: proxy.size.width * calorie / 2350, height: 8)
                        }
                }
                .frame(height: 8)
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(entry.meal.meals(mealPartTime: entry.mealPartTime).meals, id: \.hashValue) { meal in
                    HStack {
                        let isAllergy = isMealContainsAllergy(meal: meal)
                        Text(mealDisplay(meal: meal))
                            .twFont(.body1)
                            .frame(maxHeight: .infinity)
                            .foregroundColor(isAllergy ? .red : .extraBlack)

                        Spacer()
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.cardBackground
            }
            .cornerRadius(8)
        }
        .padding(16)
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }

    private func isMealContainsAllergy(meal: String) -> Bool {
        entry.allergyList
            .first { meal.contains("(\($0.number)") || meal.contains(".\($0.number)") } != nil
    }
}

private struct RectangularWidgetView: View {
    var entry: MealProvider.Entry

    var body: some View {
        let fullMeal = entry.meal.meals(mealPartTime: entry.mealPartTime).meals.joined(separator: ", ")
        Text("\(entry.mealPartTime.display) - \(mealDisplay(meal: fullMeal))")
            .lineLimit(nil)
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }
}

private struct CircularWidgetView: View {
    var body: some View {
        Image("CircularMeal")
            .resizable()
            .frame(width: 66, height: 66)
            .clipShape(Circle())
            .foregroundColor(.gray)
    }
}
