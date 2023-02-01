import Entity
import SwiftUI

struct MealView: View {
    let meal: [String]
    let calorie: Double

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(meal, id: \.self) { meal in
                        Text(meal)
                    }
                }

                HStack(alignment: .top) {
                    Spacer()

                    Text("\(String(format: "%.1f", calorie)) kcal")
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
