import ComposableArchitecture
import SwiftUI

public struct SchoolSettingView: View {
    private enum FocusField: Hashable {
        case school
        case grade
        case `class`
        case major
    }
    let store: StoreOf<SchoolSettingCore>
    @ObservedObject var viewStore: ViewStore<SchoolSettingCore.State, SchoolSettingCore.Action>
    @FocusState private var focusField: FocusField?
    
    public init(store: StoreOf<SchoolSettingCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 16) {
                if !viewStore.isFocusedSchool {
                    HStack {
                        Text(viewStore.titleMessage)
                            .font(.system(size: 16, weight: .medium))

                        Spacer()
                    }
                    .padding(.bottom, 16)

                    if !viewStore.class.isEmpty && !viewStore.schoolMajorList.isEmpty {
                        VStack {
                            TWTextField(
                                "학과",
                                text: viewStore.binding(
                                    get: \.major,
                                    send: SchoolSettingCore.Action.majorChanged
                                )
                            )
                            .disabled(true)
                        }
                        .padding(.bottom, 16)
                        .onTapGesture {
                            viewStore.send(.majorTextFieldDidTap)
                            focusField = nil
                        }
                    }

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
                )
                .focused($focusField, equals: .school)

                if viewStore.isFocusedSchool {
                    ForEach(viewStore.schoolList, id: \.schoolCode) { school in
                        HStack {
                            schoolRowView(school: school)
                                .onTapGesture {
                                    viewStore.send(.schoolRowDidSelect(school))
                                }

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
            .onChange(of: viewStore.selectedSchool) { _ in
                focusField = .grade
            }
            .onChange(of: viewStore.grade) { newValue in
                if newValue.count > 0 {
                    focusField = .class
                }
            }

            VStack {
                Spacer()

                if !viewStore.class.isEmpty && !viewStore.isFocusedSchool {
                    TWButton(title: viewStore.nextButtonTitle, style: .wide) {
                        viewStore.send(.nextButtonDidTap)
                        focusField = nil
                    }
                }
            }
        }
        .twBottomSheet(
            isShowing: viewStore.binding(
                get: \.isPresentedMajorSheet,
                send: .majorSheetDismissed
            )
        ) {
            IfLetStore(
                store.scope(state: \.schoolMajorSheetCore, action: SchoolSettingCore.Action.schoolMajorSheetCore)
            ) { store in
                SchoolMajorSheetView(store: store)
            }
            .frame(maxHeight: 400)
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
