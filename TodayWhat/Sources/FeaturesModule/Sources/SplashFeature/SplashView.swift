import ComposableArchitecture
import SwiftUI

public struct SplashView: View {
    let store: StoreOf<SplashCore>
    @ObservedObject var viewStore: ViewStoreOf<SplashCore>
    
    public init(store: StoreOf<SplashCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {}
            .onAppear {
                viewStore.send(.initialize, animation: .default)
            }
    }
}
