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
    @State var isFocusedTextField = false
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
                items: ["월", "화", "수", "목", "금", "토", "일"]
            )
            .padding(.top, 16)
            .animation(nil)

            HStack {
                Text("교시 순서")
                    .twFont(.body2, color: .extraBlack)

                Spacer()

                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)

                    Text("시간표 가져오는 중...")
                        .twFont(.body3, color: .textSecondary)
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
                        TWTextField(
                            text: viewStore.binding(
                                get: { $0.inputedTimeTables[safe: index] ?? "" },
                                send: { .timeTableInputed(index: index, content: $0) }
                            )
                        )
                        .disabled(true)
                        .onTapGesture {
                            focusIndex = index
                            isFocusedTextField = true
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusIndex == index ? Color.extraBlack : .clear, lineWidth: 1)
                        }
                        .overlay(alignment: .trailing) {
                            Button {
                                if focusIndex == index {
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
            if isFocusedTextField, let index = focusIndex {
                TWTextField(
                    text: viewStore.binding(
                        get: { $0.inputedTimeTables[safe: index] ?? "" },
                        send: { .timeTableInputed(index: index, content: $0) }
                    )
                )
                .focused($isFocused)
                .overlay(alignment: .trailing) {
                    Button {
                        if focusIndex == index {
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
            isFocusedTextField = false
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
                        .twFont(.body2, color: .extraBlack)
                }
            }
        }
        .twToast(
            isShowing: viewStore.binding(
                get: \.isShowingSuccessToast,
                send: ModifyTimeTableCore.Action.toastDismissed
            ),
            text: "\(viewStore.weekdayString) 시간표 저장완료"
        )
    }
}
