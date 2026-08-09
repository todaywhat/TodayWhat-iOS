import ComposableArchitecture
import DateUtil
import DesignSystem
import FoundationUtil
import SwiftUI
import SwiftUIUtil

public struct ModifyTimeTableView: View {
    @Environment(\.dismiss) var dismiss
    let store: StoreOf<ModifyTimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<ModifyTimeTableCore>
    @State var focusIndex: Int?
    @FocusState var isFocused: Bool

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
                items: ["월", "화", "수", "목", "금", "토", "일"],
                badgedIndices: viewStore.customizedTabs
            )
            .padding(.top, 16)
            .animation(nil)

            HStack(spacing: 8) {
                Text("교시 순서")
                    .twFont(.body2, color: .extraBlack)

                if let customStatus {
                    Text(customStatus.title)
                        .twFont(.body3, color: customStatus.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background {
                            Capsule()
                                .fill(customStatus.color.opacity(0.12))
                        }
                }

                Spacer()

                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)

                    Text("시간표 가져오는 중...")
                        .twFont(.body3, color: .textSecondary)
                } else if viewStore.isCurrentTabCustomized {
                    Button {
                        viewStore.send(.revertButtonDidTap)
                    } label: {
                        Text("되돌리기")
                            .twFont(.body3, color: .textSecondary)
                            .underline()
                    }
                }
            }
            .frame(height: 24)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .animation(nil)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    Spacer()
                        .frame(height: 1)

                    ForEach(viewStore.inputedTimeTables.indices, id: \.self) { index in
                        let textBinding: Binding<String> = viewStore.binding(
                            get: { $0.inputedTimeTables[safe: index] ?? "" },
                            send: { .timeTableInputed(index: index, content: $0) }
                        )
                        let isFocusedAtIndex: Bool = focusIndex == index
                        let strokeColor: Color = isFocusedAtIndex ? Color.extraBlack : .clear
                        TWTextField(text: textBinding)
                        .disabled(true)
                        .onTapGesture {
                            focusIndex = index
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(strokeColor, lineWidth: 1)
                        }
                        .overlay(alignment: .trailing) {
                            Button {
                                if isFocusedAtIndex {
                                    viewStore.send(.timeTableInputed(index: index, content: ""))
                                } else {
                                    viewStore.send(.removeTimeTable(index: index))
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.unselectedPrimary)
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 16)
                            }
                        }
                        .padding(.horizontal, 0.5)
                    }

                    TWButton(title: "추가 +") {
                        viewStore.send(.appendTimeTableButtonDidTap, animation: .default)
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            if let index = focusIndex {
                let bottomTextBinding: Binding<String> = viewStore.binding(
                    get: { $0.inputedTimeTables[safe: index] ?? "" },
                    send: { .timeTableInputed(index: index, content: $0) }
                )
                let isBottomFocused: Bool = focusIndex == index
                TWTextField(text: bottomTextBinding)
                .focused($isFocused)
                .overlay(alignment: .trailing) {
                    Button {
                        if isBottomFocused {
                            viewStore.send(.timeTableInputed(index: index, content: ""))
                        } else {
                            viewStore.send(.removeTimeTable(index: index))
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.unselectedPrimary)
                            .frame(width: 28, height: 28)
                            .padding(.trailing, 16)
                    }
                }
                .padding(.horizontal, 0.5)
                .onAppear {
                    isFocused = true
                }
                .padding(4)
            }
        }
        .onChange(of: isFocused, perform: { isFocused in
            guard !isFocused else { return }
            focusIndex = nil
        })
        .onChange(of: viewStore.currentTab, perform: { _ in
            focusIndex = nil
        })
        .background(Color.backgroundMain)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onLoad {
            viewStore.send(.onLoad, animation: .default)
        }
        .hideKeyboardWhenTap()
        .twBackButton(dismiss: dismiss)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("시간표 수정")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewStore.send(.saveButtonDidTap)
                } label: {
                    Text("저장")
                        .twFont(.body2, color: viewStore.hasUnsavedChanges ? .extraBlack : .unselectedPrimary)
                }
                .disabled(!viewStore.hasUnsavedChanges)
            }
        }
        .alert(store: store.scope(state: \.$alert, action: \.alert))
        .twToast(
            isShowing: viewStore.binding(
                get: \.isShowingSuccessToast,
                send: ModifyTimeTableCore.Action.toastDismissed
            ),
            text: viewStore.toastText
        )
    }

    private var customStatus: (title: String, color: Color)? {
        if viewStore.isCurrentTabEdited {
            return ("저장 안 됨", .point)
        } else if viewStore.isCurrentTabCustomized {
            return ("커스텀", .textSecondary)
        }
        return nil
    }
}
