import ComposableArchitecture
import DateUtil
import Entity
import SwiftUI
import TWColor
import TWButton

public struct NoticeView: View {
    let store: StoreOf<NoticeCore>
    @Namespace var noticeModal
    @ObservedObject var viewStore: ViewStoreOf<NoticeCore>
    @Environment(\.dismiss) var dismiss

    public init(store: StoreOf<NoticeCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewStore.noticeList, id: \.id) { notice in
                    if viewStore.selectedNotice != notice {
                        Button {
                            viewStore.send(.noticeDidSelect(notice), animation: .default)
                        } label: {
                            noticeRowView(notice: notice)
                                .padding(.horizontal, 16)
                                .matchedGeometryEffect(id: "NOTICE_MODAL", in: noticeModal, properties: .position, anchor: .center)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .overlay {
            if let selectedNotice = viewStore.selectedNotice {
                ZStack {
                    Color.black
                        .opacity(0.25)
                        .ignoresSafeArea()
                        .animation(.default, value: viewStore.selectedNotice)
                        .transition(.opacity)
                        .onTapGesture {
                            viewStore.send(.noticeModalDismissed, animation: .default)
                        }

                    noticeModalView(notice: selectedNotice)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .aspectRatio(1.0, contentMode: .fit)
                        .matchedGeometryEffect(id: "NOTICE_MODAL", in: noticeModal, properties: .position, anchor: .center)
                }
            }
        }
        .background {
            Color.veryLightGray.ignoresSafeArea()
        }
        .twBackButton(dismiss: dismiss)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("공지")
    }

    @ViewBuilder
    func noticeRowView(notice: Notice) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(notice.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.extraPrimary)

                Spacer()

                Text(notice.createdAt.toStringCustomFormat(format: "yyyy년 MM월 dd일"))
                    .font(.system(size: 12))
                    .foregroundColor(.darkGray)
            }

            Text(notice.content)
                .lineLimit(2)
                .font(.system(size: 16))
                .foregroundColor(.extraPrimary)
        }
        .padding(16)
        .background {
            Color.background
                .cornerRadius(8)
        }
    }

    @ViewBuilder
    func noticeModalView(notice: Notice) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(notice.title)
                    .lineLimit(nil)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.extraPrimary)

                Spacer()

                Text(notice.createdAt.toStringCustomFormat(format: "yyyy년 MM월 dd일"))
                    .font(.system(size: 12))
                    .foregroundColor(.darkGray)
            }

            ScrollView {
                Text(notice.content)
                    .lineLimit(nil)
                    .font(.system(size: 16))
                    .foregroundColor(.extraPrimary)
            }
        }
        .padding(16)
        .background {
            Color.background
                .cornerRadius(8)
        }
    }
}
