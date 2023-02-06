import SwiftUI

#if os(iOS)

@available(watchOS, unavailable)
public extension View {
    func twBackButton(willDismiss: @escaping () -> Void = {}, dismiss: DismissAction) -> some View {
        self
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        willDismiss()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 9, height: 16)
                            .foregroundColor(Color.primary)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}

#endif
