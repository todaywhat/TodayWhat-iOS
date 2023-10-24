import ComposableArchitecture
import SwiftUI
import EnumUtil
import TWColor
import SwiftUIUtil
import TWButton

public struct AllergySettingView: View {
    private let store: StoreOf<AllergySettingCore>
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 17), count: 3)
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

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AllergyType.allCases, id: \.hashValue) { allergy in
                        allergyColumnView(allergy: allergy)
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
        .background(Color.backgroundMain.ignoresSafeArea())
        .navigationTitle("알레르기 설정")
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
        .onChange(of: viewStore.isSaved) { newValue in
            if newValue {
                dismiss()
            }
        }
        .twBackButton(dismiss: dismiss)
    }

    @ViewBuilder
    func allergyColumnView(allergy: AllergyType) -> some View {
        let isAllergyContains = viewStore.selectedAllergyList.contains(allergy)
        let allergyForeground: Color = isAllergyContains ?
            .textPrimary :
            .unselectedPrimary

        VStack(spacing: 16) {
            Image(allergy.image)
                .renderingMode(.template)
                .frame(width: 71, height: 71, alignment: .center)
                .padding([.top, .horizontal], 16)

            Text(allergy.rawValue)
                .padding(.bottom, 16)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(allergyForeground)
        .frame(height: 136)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackgroundSecondary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(allergyForeground, lineWidth: isAllergyContains ? 2 : 1)
        }
    }
}
