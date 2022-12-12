import ComposableArchitecture
import SwiftUI
import EnumUtil
import TWColor
import SwiftUIUtil

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
        ScrollView {
            Spacer()
                .frame(height: 20)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(AllergyType.allCases, id: \.hashValue) { allergy in
                    allergyColumnView(allergy: allergy)
                        .onTapGesture {
                            viewStore.send(.allergyDidSelect(allergy))
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewStore.send(.saveButtonDidTap, animation: .default)
                } label: {
                    Text("저장")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
        }
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
            .extraPrimary :
            .extraGray

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
                .fill(Color.veryLightGray)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(allergyForeground, lineWidth: isAllergyContains ? 2 : 1)
        }
    }
}
