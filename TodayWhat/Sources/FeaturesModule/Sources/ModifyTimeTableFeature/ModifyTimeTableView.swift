import ComposableArchitecture
import SwiftUI
import TWColor
import TopTabbar
import TWButton

public struct ModifyTimeTableView: View {
    @Environment(\.dismiss) var dismiss
    let store: StoreOf<ModifyTimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<ModifyTimeTableCore>
    
    public init(store: StoreOf<ModifyTimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {
            TopTabbarView(currentTab: .constant(1), items: ["월", "화", "수", "목", "금", "토", "일"])
                .padding(.top, 16)

            Spacer()
        }
        .twBackButton(dismiss: dismiss)
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
