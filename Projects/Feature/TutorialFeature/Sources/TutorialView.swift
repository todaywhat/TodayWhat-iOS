import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct TutorialView: View {
    let store: StoreOf<TutorialCore>
    @ObservedObject var viewStore: ViewStoreOf<TutorialCore>
    @Environment(\.dismiss) var dismiss

    public init(store: StoreOf<TutorialCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(viewStore.tutorialList, id: \.id) { tutorial in
                    TutorialListRow(tutorialEntity: tutorial)
                        .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle("사용법")
        .navigationBarTitleDisplayMode(.large)
        .twBackButton(dismiss: dismiss)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}
