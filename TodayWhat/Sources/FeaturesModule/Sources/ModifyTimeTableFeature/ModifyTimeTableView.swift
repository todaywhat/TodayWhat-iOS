import ComposableArchitecture
import SwiftUI
import TWColor
import TWButton
import TWTextField
import TopTabbar
import SwiftUIUtil
import FoundationUtil

public struct ModifyTimeTableView: View {
    @Environment(\.dismiss) var dismiss
    let store: StoreOf<ModifyTimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<ModifyTimeTableCore>
    @FocusState var focusIndex: Int?
    
    public init(store: StoreOf<ModifyTimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {
            TopTabbarView(
                currentTab: viewStore.binding(
                    get: \.currentTab,
                    send: ModifyTimeTableCore.Action.tabChanged
                ),
                items: ["월", "화", "수", "목", "금", "토", "일"]
            )
            .padding(.top, 16)

            HStack {
                Text("교시 순서")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.extraBlack)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            LazyVStack(spacing: 8) {
                ForEach(viewStore.inputedTimeTables.indices, id: \.self) { index in
                    TWTextField(
                        text: viewStore.binding(
                            get: { $0.inputedTimeTables[safe: index] ?? "" },
                            send: { .timeTableInputed(index: index, content: $0) }
                        )
                    )
                    .focused($focusIndex, equals: index)
                    .overlay(alignment: .trailing) {
                        Button {
                            if focusIndex == index {
                                viewStore.send(.timeTableInputed(index: index, content: ""))
                            } else {
                                viewStore.send(.removeTimeTable(index: index), animation: .default)
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.extraGray)
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 16)
                        }
                    }
                }

                TWButton(title: "추가 +") {
                    viewStore.send(.appendTimeTableButtonDidTap, animation: .default)
                }
                .frame(width: 80, height: 40)
                .clipShape(Capsule())
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .hideKeyboardWhenTap()
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
