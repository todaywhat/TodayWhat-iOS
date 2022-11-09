import ComposableArchitecture
import SwiftUI

public struct SchoolSettingView: View {
    let store: StoreOf<SchoolSettingCore>
    @ObservedObject var viewStore: ViewStore<SchoolSettingCore.State, SchoolSettingCore.Action>
    
    public init(store: StoreOf<SchoolSettingCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        Text("")
    }
}
