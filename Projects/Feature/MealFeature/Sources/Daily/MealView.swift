import ComposableArchitecture
import DesignSystem
import Entity
import EnumUtil
import SwiftUI
import UserDefaultsClient
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

public struct MealView: View {
    let store: StoreOf<MealCore>
    @ObservedObject var viewStore: ViewStoreOf<MealCore>

    private static let mealTypes: [MealType] = [.breakfast, .lunch, .dinner]

    public init(store: StoreOf<MealCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    public var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                let date = Date()
                if let meal = viewStore.meal {
                    LazyVStack(spacing: 8) {
                        ForEach(Self.mealTypes, id: \.hashValue) { type in
                            mealListView(type: type, subMeal: meal.mealByType(type: type))
                        }
                    }
                } else if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .padding(.top, 16)
                        .accessibilityLabel("급식 정보를 불러오는 중입니다")
                        .accessibilitySortPriority(1)
                } else if viewStore.meal?.isEmpty ?? true,
                          (date.weekday == 7 || date.weekday == 1),
                          (userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false) {
                    Text("주말에도 월요일 급식을 보고 싶다면?")
                        .foregroundColor(.textSecondary)
                        .accessibilityLabel("주말 급식 설정 안내")
                        .accessibilitySortPriority(1)

                    TWButton(title: "설정하러가기", style: .cta) {
                        viewStore.send(.settingsButtonDidTap)
                    }
                    .accessibilityHint("주말 급식 표시 설정을 변경할 수 있습니다")
                    .accessibilitySortPriority(2)
                } else {
                    Text("등록된 정보를 찾지 못했어요 😥")
                        .padding(.top, 16)
                        .accessibilityLabel("급식 정보를 찾을 수 없습니다")
                        .accessibilitySortPriority(1)
                }
            }
            .onLoad {
                viewStore.send(.onLoad)
            }
            .onAppear {
                viewStore.send(.onAppear, animation: .default)
            }
            .onChange(of: viewStore.currentTimeMealType) { mealType in
                withAnimation(.easeInOut(duration: 0.5)) {
                    scrollProxy.scrollTo(mealType, anchor: .top)
                }
            }
            .refreshable {
                viewStore.send(.refresh, animation: .default)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    @ViewBuilder
    private func mealListView(type: MealType, subMeal: Meal.SubMeal) -> some View {
        let calText: String = String(format: "%.1f", subMeal.cal)
        let typeDisplay: String = type.display
        let subLabelText: String = "\(calText) Kcal"
        let accessibilityText: String = "\(typeDisplay) 메뉴, \(calText) 칼로리"

        LabelledDivider(label: typeDisplay, subLabel: subLabelText)
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .id(type)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityText)
            .accessibilitySortPriority(1)

        LazyVStack {
            ForEach(subMeal.meals, id: \.hashValue) { meal in
                let display = mealDisplay(meal: meal)
                let containsAllergy = isMealContainsAllergy(meal: meal)

                HStack {
                    Text(display)
                        .twFont(.headline4, color: containsAllergy ? .point : .textPrimary)

                    Spacer()

                    if containsAllergy {
                        Image.allergy
                            .renderingMode(.template)
                            .foregroundColor(.point)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cardBackground)
                }
                .padding(.horizontal, 16)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(display)")
                .accessibilityHint(containsAllergy ? "알레르기 유발 식품이 포함되어 있습니다" : "")
                .accessibilitySortPriority(2)
                .contentShape(Rectangle())
                .onLongPressGesture {
                    copyMealToClipboard(display)
                }
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

private func copyMealToClipboard(_ text: String) {
#if canImport(UIKit)
    UIPasteboard.general.string = text
#elseif canImport(AppKit)
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
#endif
}
