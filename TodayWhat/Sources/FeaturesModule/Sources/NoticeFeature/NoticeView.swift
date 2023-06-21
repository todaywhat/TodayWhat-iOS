import ComposableArchitecture
import SwiftUI
import TWColor

public struct NoticeView: View {
    let store: StoreOf<NoticeCore>
    @ObservedObject var viewStore: ViewStoreOf<NoticeCore>
    @Environment(\.dismiss) var dismiss

    public init(store: StoreOf<NoticeCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.extraBlack)
                }
            }

            Spacer()

            Text("\(viewStore.state.emegencyNotice.content)")
                .lineLimit(nil)
                .font(.system(size: 20))
                .padding(.horizontal, 17)

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
