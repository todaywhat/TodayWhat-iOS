import ComposableArchitecture
import SwiftUI

public struct SchoolSettingView: View {
    private enum FocusField: Hashable {
        case school
        case grade
        case `class`
    }
    let store: StoreOf<SchoolSettingCore>
    @ObservedObject var viewStore: ViewStore<SchoolSettingCore.State, SchoolSettingCore.Action>
    @FocusState private var focusField: FocusField?
    
    public init(store: StoreOf<SchoolSettingCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack(spacing: 16) {
            if !viewStore.isFocusedSchool {
                HStack {
                    Text(viewStore.titleMessage)
                        .font(.system(size: 16, weight: .medium))

                    Spacer()
                }
                .padding(.bottom, 16)

                if !viewStore.grade.isEmpty {
                    TWTextField(
                        "반",
                        text: viewStore.binding(
                            get: \.class,
                            send: SchoolSettingCore.Action.classChanged
                        )
                    )
                    .focused($focusField, equals: .class)
                    .keyboardType(.numberPad)
                    .padding(.bottom, 16)
                }

                if !viewStore.school.isEmpty {
                    TWTextField(
                        "학년",
                        text: viewStore.binding(
                            get: \.grade,
                            send: SchoolSettingCore.Action.gradeChanged
                        )
                    )
                    .focused($focusField, equals: .grade)
                    .keyboardType(.numberPad)
                    .padding(.bottom, 16)
                }
            }

            TWTextField(
                "학교이름",
                text: viewStore.binding(
                    get: \.school,
                    send: SchoolSettingCore.Action.schoolChanged
                )
            ) {
                focusField = .grade
            }
            .focused($focusField, equals: .school)

            if viewStore.isFocusedSchool {
                ForEach(viewStore.schoolList, id: \.schoolCode) { school in
                    HStack {
                        schoolRowView(school: school)

                        Spacer()
                    }
                }
            }

            Spacer()
        }
        .animation(.default, value: viewStore.grade)
        .animation(.default, value: viewStore.class)
        .animation(.default, value: viewStore.school)
        .padding(.horizontal, 16)
        .onChange(of: focusField) { newValue in
            viewStore.send(.schoolFocusedChanged(newValue == .school), animation: .default)
        }
        .onChange(of: viewStore.grade) { newValue in
            if newValue.count > 0 {
                focusField = .class
            }
        }
    }

    @ViewBuilder
    func schoolRowView(school: School) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(school.name)
                .font(.system(size: 14, weight: .bold))

            Text(school.location)
                .font(.system(size: 12))
                .foregroundColor(.extraGray)
        }
    }
}
