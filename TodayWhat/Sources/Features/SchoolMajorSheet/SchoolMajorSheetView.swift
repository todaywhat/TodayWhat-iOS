import ComposableArchitecture
import SwiftUI

public struct SchoolMajorSheetView: View {
    let store: StoreOf<SchoolMajorSheetCore>
    @ObservedObject var viewStore: ViewStore<SchoolMajorSheetCore.State, SchoolMajorSheetCore.Action>
    
    public init(store: StoreOf<SchoolMajorSheetCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 32) {
                    ForEach(viewStore.majorList, id: \.self) { major in
                        Button {
                            viewStore.send(.majorRowDidSelect(major), animation: .default)
                        } label: {
                            schoolMajorRowView(major: major)
                                .padding(2)
                        }

                    }
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 32)
        }
    }

    @ViewBuilder
    private func schoolMajorRowView(major: String) -> some View {
        HStack {
            Text(major)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.extraPrimary)

            Spacer()

            TWRadioButton(isChecked: viewStore.selectedMajor == major) {
                viewStore.send(.majorRowDidSelect(major), animation: .default)
            }
        }
    }
}
