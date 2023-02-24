import Entity
import SwiftUI

struct MealView: View {
    let meal: [String]
    let calorie: Double

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(String(format: "%.1f", calorie)) kcal")
                            .bold()

                        ForEach(meal, id: \.self) { meal in
                            Text(meal)
                        }

                        Spacer()

                        HStack {
                            Spacer()

                            Text("🔄 새로고침 cmd + r")
                                .font(.caption2)
                        }
                    }

                    Spacer()
                }
            }
            .padding(8)
        }
    }
}

struct MealView_Previews: PreviewProvider {
    static var previews: some View {
        MealView(meal: ["a", "b", "c", "d"], calorie: 0)
    }
}
