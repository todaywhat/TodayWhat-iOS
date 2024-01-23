import ComposableArchitecture
import DateUtil
import DesignSystem
import Entity
import SwiftUI

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
                                .matchedGeometryEffect(
                                    id: "NOTICE_MODAL\(notice.id)",
                                    in: noticeModal,
                                    properties: .position,
                                    anchor: .center
                                )
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
                    Color.lightBox
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
                        .matchedGeometryEffect(
                            id: "NOTICE_MODAL\(selectedNotice.id)",
                            in: noticeModal,
                            properties: .position,
                            anchor: .center
                        )
                }
            }
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
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
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                Text(notice.createdAt.toStringCustomFormat(format: "yyyy년 MM월 dd일"))
                    .font(.system(size: 12))
                    .foregroundColor(.textPrimary)
            }

            Text(notice.content)
                .lineLimit(2)
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background {
            Color.cardBackgroundSecondary
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
                    .foregroundColor(.textPrimary)

                Spacer()

                Text(notice.createdAt.toStringCustomFormat(format: "yyyy년 MM월 dd일"))
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }

            ScrollView {
                Text(notice.content.replacingOccurrences(of: "\\n", with: "\n"))
                    .lineLimit(nil)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
            }
        }
        .padding(16)
        .background {
            Color.backgroundMain
                .cornerRadius(8)
        }
    }
}
