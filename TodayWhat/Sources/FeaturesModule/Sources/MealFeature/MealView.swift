import ComposableArchitecture
import SwiftUI
import EnumUtil
import Entity
import LabelledDivider
import TWColor
import TWButton
import UserDefaultsClient

public struct MealView: View {
    let store: StoreOf<MealCore>
    @ObservedObject var viewStore: ViewStoreOf<MealCore>
    
    public init(store: StoreOf<MealCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some View {
        ScrollView {
            let date = Date()
            if let meal = viewStore.meal {
                LazyVStack(spacing: 8) {
                    ForEach([MealType.breakfast, .lunch, .dinner], id: \.hashValue) { type in
                        mealListView(type: type, subMeal: meal.mealByType(type: type))
                    }
                }
            } else if viewStore.isLoading {
                ProgressView()
                    .progressViewStyle(.automatic)
                    .padding(.top, 16)
            } else if viewStore.meal?.isEmpty ?? true,
                      (date.weekday == 7 || date.weekday == 1),
                      userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false {
                Text("주말에도 월요일 급식을 보고 싶다면?")
                    .foregroundColor(.extraGray)

                TWButton(title: "설정하러가기", style: .cta) {
                    viewStore.send(.settingsButtonDidTap)
                }
            }
            else {
                Text("등록된 정보를 찾지 못했어요 😥")
                    .padding(.top, 16)
            }
        }
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
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
                    Text(mealDisplay(meal: meal))
                        .font(.system(size: 16, weight: .bold))

                    Spacer()

                    if isMealContainsAllergy(meal: meal) {
                        Image("Allergy")
                            .renderingMode(.original)
                    }
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

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }

    private func isMealContainsAllergy(meal: String) -> Bool {
        return viewStore.allergyList
            .first { meal.contains("(\($0.number)") || meal.contains(".\($0.number)") } != nil
    }
}

private extension Meal {
    var isEmpty: Bool {
        return self.breakfast.meals.isEmpty &&
        self.lunch.meals.isEmpty &&
        self.dinner.meals.isEmpty
    }
}
