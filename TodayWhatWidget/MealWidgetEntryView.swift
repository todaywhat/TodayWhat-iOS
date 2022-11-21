import SwiftUI
import WidgetKit
import Intents
import Dependencies

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
            SmallMealWidgetView(meals: ["친환경백미찹쌀밥", "매콤어묵무국", "닭갈비", "청포묵무침", "치즈소떡소떡&양념소스", "배추김치", "상큼이주스", "닭가슴살양상추샐러드&오리엔탈"])

        case .systemMedium:
            MediumMealWidgetView(meals: ["친환경백미찹쌀밥", "매콤어묵무국", "닭갈비", "청포묵무침", "치즈소떡소떡&양념소스", "배추김치", "상큼이주스", "닭가슴살양상추샐러드&오리엔탈"])

        case .systemLarge:
            LargeMealWidgetView(meals: ["친환경백미찹쌀밥", "매콤어묵무국", "닭갈비", "청포묵무침", "치즈소떡소떡&양념소스", "배추김치", "상큼이주스", "닭가슴살양상추샐러드&오리엔탈"])

        default:
            EmptyView()
        }
    }
}

private struct SmallMealWidgetView: View {
    var meals: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("[아침]")
                .frame(maxHeight: .infinity)
                .font(.system(size: 12).bold())

            ForEach(meals, id: \.hashValue) { meal in
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
    var meals: [String]
    private let rows = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("ONMI")
                    .font(.custom("Fraunces72pt-Black", size: 16))

                Text("[아침]")
                    .font(.system(size: 12))

                Spacer()

                Text("2983 KCAL")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Gray"))
            }

            LazyHGrid(rows: rows) {
                ForEach(meals, id: \.hashValue) { meal in
                    HStack {
                        Text(meal)
                            .frame(maxHeight: .infinity)
                            .font(.system(size: 12))

                        Spacer()
                    }
                    .padding(.horizontal, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("VeryLightGray")
            }
            .cornerRadius(8)
        }
        .padding(12)
    }
}

private struct LargeMealWidgetView: View {
    var meals: [String]

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("ONMI")
                    .font(.custom("Fraunces72pt-Black", size: 16))

                Text("[아침]")
                    .font(.system(size: 12))

                Spacer()

                Text("2983 KCAL")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Gray"))
            }

            RoundedRectangle(cornerRadius: 2)
                .frame(height: 8)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(meals, id: \.hashValue) { meal in
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

