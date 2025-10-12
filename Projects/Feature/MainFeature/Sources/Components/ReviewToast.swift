import Dependencies
import DesignSystem
import FeatureFlagClient
import SwiftUI

struct ReviewToast: View {
    @Dependency(\.featureFlagClient) private var featureFlagClient
    let onTap: () -> Void

    var body: some View {
        let baseButton = Button {
            onTap()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "star.bubble.fill")
                    .foregroundColor(.yellow)

                Text(featureFlagClient.getString(.reviewText) ?? "오늘뭐임을 더 발전시킬 수 있게 리뷰 부탁드려요!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.extraBlack)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }

        if #available(iOS 26.0, *) {
            baseButton
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            baseButton
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.extraWhite)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
    }
}
