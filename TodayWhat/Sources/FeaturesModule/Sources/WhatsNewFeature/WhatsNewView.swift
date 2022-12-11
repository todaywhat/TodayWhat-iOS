import ComposableArchitecture
import SwiftUI
import TWColor
import TWButton

public struct WhatsNewView: View {
    private let store: StoreOf<WhatsNewCore>
    
    public init(store: StoreOf<WhatsNewCore>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Text("오늘 뭐임 시작하기")
                .font(.system(size: 36, weight: .heavy))
                .padding(.top, 64)

            VStack(alignment: .leading) {
                detailFeature(title: "위젯", description: "앱을 키지 않고도 확인할 수 있습니다.") {
                    Image(systemName: "rectangle.grid.2x2.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.extraPrimary)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.top, 32)

            Spacer()

            TWButton(title: "계속") {
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    func detailFeature(
        title: String,
        description: String,
        @ViewBuilder icon: () -> some View
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            icon()

            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))

                Text(description)
                    .foregroundColor(.extraGray)
            }
        }
    }
}
