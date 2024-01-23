import DesignSystem
import Entity
import EnumUtil
import SwiftUI

struct MealView: View {
    let meal: [String]
    let allergyList: [AllergyType]
    let calorie: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(String(format: "%.1f", calorie)) kcal")
                    .bold()

                ForEach(meal, id: \.self) { meal in
                    Text(mealDisplay(meal: meal))
                        .foregroundColor(
                            isMealContainsAllergy(meal: meal)
                                ? .red
                                : .textPrimary
                        )
                }
            }

            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            Text("🔄 새로고침 cmd + r")
                .font(.caption2)
        }
        .padding(8)
        .frame(alignment: .topLeading)
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }

    private func isMealContainsAllergy(meal: String) -> Bool {
        return allergyList
            .first { meal.contains("(\($0.number)") || meal.contains(".\($0.number)") } != nil
    }
}

struct MealView_Previews: PreviewProvider {
    static var previews: some View {
        MealView(meal: ["a", "b", "c", "d"], allergyList: [], calorie: 0)
    }
}
