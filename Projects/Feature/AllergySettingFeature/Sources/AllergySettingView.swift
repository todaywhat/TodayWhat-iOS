import ComposableArchitecture
import DesignSystem
import EnumUtil
import SwiftUI
import SwiftUIUtil

public struct AllergySettingView: View {
    private let store: StoreOf<AllergySettingCore>
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewStore: ViewStoreOf<AllergySettingCore>

    public init(store: StoreOf<AllergySettingCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {
            ScrollView {
                Spacer()
                    .frame(height: 20)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(AllergyType.allCases.indices, id: \.self) { index in
                        let allergy = AllergyType.allCases[safe: index] ?? .turbulence

                        allergyColumnView(index: index, allergy: allergy)
                            .onTapGesture {
                                viewStore.send(.allergyDidSelect(allergy), animation: .default)
                            }
                            .animation(nil, value: viewStore.selectedAllergyList)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewStore.allergyDidTap {
                TWButton(title: "저장") {
                    viewStore.send(.saveButtonDidTap)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .background(Color.backgroundSecondary.ignoresSafeArea())
        .navigationTitle("알레르기")
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
        .twBackButton(dismiss: dismiss)
    }

    @ViewBuilder
    func allergyColumnView(index: Int, allergy: AllergyType) -> some View {
        let isAllergyContains = viewStore.selectedAllergyList.contains(allergy)
        let cardForegroundColor: Color = isAllergyContains ?
            .extraBlack :
            .unselectedPrimary

        HStack(alignment: .center, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.backgroundSecondary)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(allergy.image)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 36, height: 36, alignment: .center)
                }
                .padding(.leading, 20)

            Text(allergy.rawValue)
                .twFont(.body3)
        }
        .foregroundColor(cardForegroundColor)
        .frame(height: 96)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackgroundSecondary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(cardForegroundColor, lineWidth: isAllergyContains ? 2 : 0)
        }
        .overlay(alignment: .topTrailing) {
            Text("\(index + 1)")
                .twFont(.body2)
                .foregroundColor(cardForegroundColor)
                .padding(.top, 8)
                .padding(.trailing, 16)
        }
    }
}
