import SwiftUI
import WidgetKit
import Intents
import Dependencies
import Entity

struct MealWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    private let entry: Provider.Entry

    public init(entry: Provider.Entry) {
        self.entry = entry
    }

    var body: some View {
        widgetBody()
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
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("[\(entry.mealPartTime.display)]")
                .frame(maxHeight: .infinity)
                .font(.system(size: 12).bold())

            ForEach(entry.meal.meals(mealPartTime: entry.mealPartTime).meals, id: \.hashValue) { meal in
                HStack {
                    Text(meal)
                        .frame(maxHeight: .infinity)
                        .font(.system(size: 12))

                    Spacer()
                }
            }
        }
        .padding(12)
    }
}

private struct MediumMealWidgetView: View {
    var entry: Provider.Entry
    private let rows = Array(repeating: GridItem(.flexible(), spacing: nil), count: 4)

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("ONMI")
                        .font(.custom("Fraunces72pt-Black", size: 16))

                    Text("[\(entry.mealPartTime.display)]")
                        .font(.system(size: 12))

                    Spacer()

                    Text("\(entry.meal.meals(mealPartTime: entry.mealPartTime).cal) kcal")
                        .font(.system(size: 12))
                        .foregroundColor(Color("Gray"))
                }
                .padding(.horizontal, 4)

                LazyHGrid(rows: rows, spacing: 0) {
                    ForEach(entry.meal.meals(mealPartTime: entry.mealPartTime).meals, id: \.hashValue) { meal in
                        HStack(spacing: 0) {
                            Text(meal)
                                .frame(maxHeight: .infinity)
                                .font(.system(size: 12))

                            Spacer()
                        }
                        .frame(maxWidth: (proxy.size.width / 2) - 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(8)
                .background {
                    Color("VeryLightGray")
                        .cornerRadius(8)
                }
                .padding([.bottom, .horizontal], 4)
            }
            .padding(12)
        }
    }
}

private struct LargeMealWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("ONMI")
                    .font(.custom("Fraunces72pt-Black", size: 16))

                Text("[\(entry.mealPartTime.display)]")
                    .font(.system(size: 12))

                Spacer()

                Text("\(entry.meal.meals(mealPartTime: entry.mealPartTime).cal) Kcal")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Gray"))
            }

            RoundedRectangle(cornerRadius: 2)
                .fill(Color("LightGray"))
                .frame(height: 8)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(entry.meal.meals(mealPartTime: entry.mealPartTime).meals, id: \.hashValue) { meal in
                    HStack {
                        Text(meal)
                            .frame(maxHeight: .infinity)
                            .font(.system(size: 16))

                        Spacer()
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("VeryLightGray")
            }
            .cornerRadius(8)
        }
        .padding(16)
    }
}

