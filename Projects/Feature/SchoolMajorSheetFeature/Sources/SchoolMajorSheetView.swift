import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct SchoolMajorSheetView: View {
    let store: StoreOf<SchoolMajorSheetCore>
    @ObservedObject var viewStore: ViewStoreOf<SchoolMajorSheetCore>

    public init(store: StoreOf<SchoolMajorSheetCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(viewStore.majorList, id: \.self) { major in
                        let isSelected: Bool = viewStore.selectedMajor == major
                        let accessLabel: String = "\(major) \(isSelected ? "선택됨" : "선택안됨")"

                        Button {
                            viewStore.send(.majorRowDidSelect(major), animation: .default)
                        } label: {
                            schoolMajorRowView(major: major, isSelected: isSelected)
                        }
                        .padding(.horizontal, 32)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(accessLabel)
                        .accessibilityHint("이 학과를 선택하려면 두 번 탭하세요")
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
            }
            .padding(.top, 32)
            .accessibilityLabel("학과 선택 목록")
        }
    }

    @ViewBuilder
    private func schoolMajorRowView(major: String, isSelected: Bool) -> some View {
        HStack {
            Text(major)
                .twFont(.headline4, color: .textPrimary)

            Spacer()

            TWRadioButton(isChecked: isSelected) {
                viewStore.send(.majorRowDidSelect(major), animation: .default)
            }
        }
        .padding(.vertical, 16)
    }
}
