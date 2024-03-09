import DesignSystem
import Nuke
import NukeUI
import SwiftUI
import TutorialClient

struct TutorialListRow: View {
    let tutorialEntity: TutorialEntity
    @State var fraction: Float = 0

    init(tutorialEntity: TutorialEntity) {
        self.tutorialEntity = tutorialEntity
        ImagePipeline.shared.cache.removeAll()
    }

    var body: some View {
        VStack(spacing: 0) {
            LazyImage(url: URL(string: tutorialEntity.thumbnailImageURL)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    Color.gray.overlay {
                        Text(String(format: "%.2f%", fraction))
                            .twFont(.headline2, color: .absoluteWhite)
                    }
                    .onReceive(state.progress.objectWillChange, perform: { _ in
                        fraction = state.progress.fraction
                    })
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.7, contentMode: .fit)

            HStack {
                Text(tutorialEntity.title)
                    .twFont(.headline3, color: .extraBlack)

                Spacer()

                Image.chevronRight
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.extraWhite)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Color.absoluteBlack.opacity(0.12),
            radius: 24,
            x: 0,
            y: 4
        )
    }
}
