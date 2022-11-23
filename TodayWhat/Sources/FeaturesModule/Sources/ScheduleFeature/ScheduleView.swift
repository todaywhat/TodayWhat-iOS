import ComposableArchitecture
import SwiftUI

public struct ScheduleView: View {
    let store: StoreOf<ScheduleCore>
    @ObservedObject var viewStore: ViewStoreOf<ScheduleCore>
    
    public init(store: StoreOf<ScheduleCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView {
            Text("Schedule")
        }
    }
}
