import ComposableArchitecture
import SwiftUI

public struct RootView: View {
    let store: StoreOf<RootCore>
    @ObservedObject var viewStore: ViewStoreOf<RootCore>
    
    public init(store: StoreOf<RootCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        EmptyView()
    }
}
