import ComposableArchitecture
import EnumUtil
import SwiftUI
import SwiftUIUtil
import DesignSystem

struct AllergyView: View {
    let store: StoreOf<AllergyCore>
    @ObservedObject var viewStore: ViewStoreOf<AllergyCore>
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 17), count: 3)

    init(store: StoreOf<AllergyCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
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
        .navigationTitle("알레르기 설정")
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
    }

    @ViewBuilder
    func allergyColumnView(allergy: AllergyType) -> some View {
        let isAllergyContains = viewStore.selectedAllergyList.contains(allergy)
        let allergyForeground: Color = isAllergyContains ?
            .textPrimary :
            .unselectedPrimary

        VStack(spacing: 16) {
            Image(allergy.image)
                .resizable()
                .renderingMode(.template)
                .frame(width: 36, height: 36, alignment: .center)
                .padding([.top, .horizontal], 16)

            Text(allergy.rawValue)
                .padding(.bottom, 16)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(allergyForeground)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(allergyForeground, lineWidth: isAllergyContains ? 2 : 1)
        }
    }
}

struct AllergyView_Previews: PreviewProvider {
    static var previews: some View {
        AllergyView(
            store: .init(
                initialState: .init(),
                reducer: AllergyCore()
            )
        )
    }
}
