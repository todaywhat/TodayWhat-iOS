import ComposableArchitecture
import SwiftUI

public struct TimeTableView: View {
    let store: StoreOf<TimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<TimeTableCore>
    
    public init(store: StoreOf<TimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView {
            Text("Schedule")
        }
    }
}
