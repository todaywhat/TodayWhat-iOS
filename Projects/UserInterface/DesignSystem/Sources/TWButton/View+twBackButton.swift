import SwiftUI

#if os(iOS)

@available(watchOS, unavailable)
public extension View {
    @ViewBuilder
    func twBackButton(willDismiss: @escaping () -> Void = {}, dismiss: DismissAction) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            self
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button {
                            willDismiss()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .frame(width: 9, height: 16)
                                .foregroundColor(Color.extraBlack)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
        }
    }
}

#endif
