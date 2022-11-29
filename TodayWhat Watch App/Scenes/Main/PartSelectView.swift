import SwiftUI
import SwiftUIUtil
import EnumUtil

struct PartSelectView: View {
    var selectedPart: DisplayInfoPart
    var action: (DisplayInfoPart) -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sceneFlowState: SceneFlowState
    
    init(
        selectedPart: DisplayInfoPart,
        action: @escaping (DisplayInfoPart) -> Void
    ) {
        self.selectedPart = selectedPart
        self.action = action
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                optionView(.breakfast, corners: [.topLeft, .topRight])
                
                Divider()
                
                optionView(.lunch, corners: [])
                
                Divider()
                
                optionView(.dinner, corners: [.bottomLeft, .bottomRight])
                
                optionView(DisplayInfoPart.timeTable)
                    .padding(.top, 8)
            }
        }
    }
    
    @ViewBuilder
    func optionView(
        _ part: DisplayInfoPart,
        corners: UIRectCorner = .allCorners
    ) -> some View {
        HStack {
            Text(part.display)
            
            Spacer()
            
            if part == selectedPart {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Main"))
        .cornerRadius(8, corners: corners)
        .onTapGesture {
            dismiss()
            action(part)
        }
    }
}

struct PartSelectView_Previews: PreviewProvider {
    static var previews: some View {
        PartSelectView(selectedPart: .breakfast) { _ in }
    }
}
