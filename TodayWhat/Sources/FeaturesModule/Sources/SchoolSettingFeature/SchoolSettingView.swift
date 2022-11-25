import ComposableArchitecture
import SwiftUI
import Entity
import TWTextField
import TWButton
import TWColor
import TWBottomSheet
import SchoolMajorSheetFeature
import SwiftUIUtil

public struct SchoolSettingView: View {
    private enum FocusField: Hashable {
        case school
        case grade
        case `class`
        case major
    }
    let store: StoreOf<SchoolSettingCore>
    private let isNavigationPushed: Bool
    @ObservedObject var viewStore: ViewStoreOf<SchoolSettingCore>
    @FocusState private var focusField: FocusField?
    @Environment(\.dismiss) var dismiss
    
    public init(
        store: StoreOf<SchoolSettingCore>,
        isNavigationPushed: Bool = false
    ) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.isNavigationPushed = isNavigationPushed
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 16) {
                if !viewStore.isFocusedSchool {
                    HStack {
                        Text(viewStore.titleMessage)
                            .font(.system(size: 20, weight: .medium))

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
                            viewStore.send(.majorTextFieldDidTap, animation: .default)
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
                        ) {
                            viewStore.send(.majorTextFieldDidTap, animation: .default)
                            focusField = nil
                        }
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
                        ) {
                            focusField = .class
                        }
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
                    focusField = .school
                }
                .focused($focusField, equals: .school)

                if viewStore.isFocusedSchool {
                    if viewStore.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        ForEach(viewStore.schoolList, id: \.schoolCode) { school in
                            HStack {
                                schoolRowView(school: school)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background {
                                Color.background
                            }
                            .onTapGesture {
                                viewStore.send(.schoolRowDidSelect(school), animation: .default)
                                focusField = .grade
                            }
                        }
                    }
                }

                Spacer()
            }
            .animation(.default, value: viewStore.grade)
            .animation(.default, value: viewStore.class)
            .animation(.default, value: viewStore.school)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .onChange(of: focusField) { newValue in
                viewStore.send(.schoolFocusedChanged(newValue == .school), animation: .default)
            }
            .onChange(of: viewStore.grade) { newValue in
                if newValue.count > 0 {
                    focusField = .class
                }
            }

            VStack {
                Spacer()

                if !viewStore.class.isEmpty &&
                    !viewStore.grade.isEmpty &&
                    !viewStore.isFocusedSchool &&
                    !viewStore.school.isEmpty {
                    TWButton(title: viewStore.nextButtonTitle, style: .wide) {
                        viewStore.send(.nextButtonDidTap, animation: .default)
                        focusField = nil
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                focusField = .school
            }
        }
        .background {
            Color.background
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
        .if(isNavigationPushed) {
            $0.twBackButton(dismiss: dismiss)
        }
    }

    @ViewBuilder
    func schoolRowView(school: School) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(school.name)
                .font(.system(size: 16, weight: .bold))

            Text(school.location)
                .font(.system(size: 14))
                .foregroundColor(.extraGray)
        }
    }
}
