import ComposableArchitecture
import SwiftUI
import TWColor

public struct ModifyTimeTableView: View {
    let store: StoreOf<ModifyTimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<ModifyTimeTableCore>
    
    public init(store: StoreOf<ModifyTimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("시간표 수정")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Text("저장")
                        .font(.system(size: 14))
                        .foregroundColor(.extraPrimary)
                }
            }
        }
    }
}
