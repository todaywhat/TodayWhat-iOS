import ComposableArchitecture
import SwiftUI
import EnumUtil
import Entity
import LabelledDivider
import TWColor

public struct MealView: View {
    let store: StoreOf<MealCore>
    @ObservedObject var viewStore: ViewStoreOf<MealCore>
    
    public init(store: StoreOf<MealCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        viewStore.send(.initialize)
    }

    public var body: some View {
        ScrollView {
            if let meal = viewStore.meal {
                LazyVStack(spacing: 8) {
                    ForEach([MealType.breakfast, .lunch, .dinner], id: \.hashValue) { type in
                        mealListView(type: type, subMeal: meal.mealByType(type: type))
                    }
                }
            }
        }
        .refreshable {
            viewStore.send(.refresh, animation: .default)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    @ViewBuilder
    private func mealListView(type: MealType, subMeal: Meal.SubMeal) -> some View {
        LabelledDivider(label: type.display)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
        
        LazyVStack {
            ForEach(subMeal.meals, id: \.hashValue) { meal in
                HStack {
                    Text(meal)
                        .font(.system(size: 16, weight: .bold))

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.veryLightGray)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 24)
    }
}
