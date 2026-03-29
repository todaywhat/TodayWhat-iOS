import DesignSystem
import SwiftUI

struct ReOnboardingSheetView: View {
    let onChangeSchool: () -> Void
    let onChangeGradeClass: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 32)

            Text("🎒")
                .font(.system(size: 48))
                .padding(.bottom, 12)

            Text("새 학기!")
                .twFont(.headline2)
                .foregroundStyle(Color.extraBlack)
                .padding(.bottom, 4)

            Text("학교나 반이 바뀌었나요?")
                .twFont(.body1)
                .foregroundStyle(Color.textSecondary)
                .padding(.bottom, 32)

            VStack(spacing: 12) {
                Button {
                    onChangeSchool()
                } label: {
                    Text("학교 변경")
                        .twFont(.body1)
                        .foregroundStyle(Color.extraWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.extraBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("학교 변경")
                .accessibilityHint("학교를 변경할 수 있는 설정으로 이동합니다")

                Button {
                    onChangeGradeClass()
                } label: {
                    Text("학년·반만 변경")
                        .twFont(.body1)
                        .foregroundStyle(Color.extraBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("학년 반 변경")
                .accessibilityHint("학년과 반만 변경할 수 있는 설정으로 이동합니다")

                Button {
                    onDismiss()
                } label: {
                    Text("그대로예요")
                        .twFont(.body2)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.vertical, 8)
                }
                .accessibilityLabel("그대로예요")
                .accessibilityHint("변경 사항 없이 닫습니다")
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("새 학기 안내")
    }
}

struct ReOnboardingSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}
