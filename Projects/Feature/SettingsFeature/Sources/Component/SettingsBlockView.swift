import SwiftUI
import UIKit

struct SettingsBlockView<Content: View>: View {
    let spacing: CGFloat
    let corners: UIRectCorner
    let action: (() -> Void)?
    let label: () -> Content

    init(
        spacing: CGFloat = 16,
        corners: UIRectCorner = .allCorners,
        action: (() -> Void)? = nil,
        label: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.corners = corners
        self.action = action
        self.label = label
    }

    var body: some View {
        if let action {
            Button(action: action) {
                VStack(alignment: .leading, spacing: spacing) {
                    label()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background {
                    Color.cardBackgroundSecondary
                }
                .cornerRadius(16, corners: corners)
            }
        } else {
            VStack(alignment: .leading, spacing: spacing) {
                label()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background {
                Color.cardBackgroundSecondary
            }
            .cornerRadius(16, corners: corners)
        }
    }
}
