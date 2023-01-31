import ComposableArchitecture
import SwiftUI
import SwiftUIUtil
import TWColor

struct ContentView: View {
    let store: StoreOf<ContentCore>
    @ObservedObject var viewStore: ViewStoreOf<ContentCore>

    init(store: StoreOf<ContentCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            HStack {
                infoListView()

                optionPanelView()
            }
            .padding(20)
            .frame(maxHeight: .infinity)
        }
        .frame(width: 500, height: 400)
    }

    @ViewBuilder
    func infoListView() -> some View {
        VStack {
            
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func optionPanelView() -> some View {
        VStack {
            ForEach(DisplayInfoPart.allCases, id: \.self) { item in
                let isSelected: Bool = item == viewStore.selectedPart
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.extraPrimary : .extraGray)
                    .frame(maxHeight: .infinity)
                    .overlay(
                        HStack {
                            Text(item.display)
                                .foregroundColor(isSelected ? Color.black : .primary)

                            Spacer()
                        }
                        .padding(8)
                    )
                    .onTapGesture {
                        viewStore.send(.partDidSelect(item), animation: .default)
                    }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 120)
        .frame(maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: .init(
                initialState: .init(),
                reducer: ContentCore()
            )
        )
    }
}
