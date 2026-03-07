import ComposableArchitecture
import DesignSystem
import Entity
import SchoolMajorSheetFeature
import SwiftUI
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
    @FocusState private var focusField: FocusField?
    @Environment(\.dismiss) var dismiss

    public init(
        store: StoreOf<SchoolSettingCore>,
        isNavigationPushed: Bool = false
    ) {
        self.store = store
        self.isNavigationPushed = isNavigationPushed
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let hasClassAndMajorList: Bool = !viewStore.class.isEmpty && !viewStore.schoolMajorList.isEmpty
            let titleMessage: String = viewStore.titleMessage
            let gradeValue: String = viewStore.grade
            let classValue: String = viewStore.class
            let schoolValue: String = viewStore.school
            let isFocusedSchool: Bool = viewStore.isFocusedSchool
            let nextButtonTitle: String = viewStore.nextButtonTitle

            let majorBinding: Binding<String> = viewStore.binding(
                get: \.major,
                send: SchoolSettingCore.Action.majorChanged
            )
            let classBinding: Binding<String> = viewStore.binding(
                get: \.class,
                send: SchoolSettingCore.Action.classChanged
            )
            let gradeBinding: Binding<String> = viewStore.binding(
                get: \.grade,
                send: SchoolSettingCore.Action.gradeChanged
            )
            let schoolBinding: Binding<String> = viewStore.binding(
                get: \.school,
                send: SchoolSettingCore.Action.schoolChanged
            )
            let majorSheetBinding: Binding<Bool> = viewStore.binding(
                get: \.isPresentedMajorSheet,
                send: .majorSheetDismissed
            )

            let showBottomButton: Bool = !classValue.isEmpty &&
                !gradeValue.isEmpty &&
                !isFocusedSchool &&
                !schoolValue.isEmpty

            ZStack {
                VStack(spacing: 34) {
                    if !isFocusedSchool {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(titleMessage)
                                    .twFont(.headline2, color: .extraBlack)
                                    .accessibilityLabel(titleMessage)
                                    .accessibilityAddTraits(.isHeader)

                                if hasClassAndMajorList {
                                    Text("학과는 없으면 안해도 괜찮아요!")
                                        .twFont(.body3, color: .extraBlack)
                                        .accessibilityLabel("학과 입력은 선택사항입니다")
                                }
                            }

                            Spacer()
                        }
                        .padding(.bottom, 16)

                        if hasClassAndMajorList {
                            VStack {
                                TWTextField(
                                    "학과",
                                    text: majorBinding
                                )
                                .disabled(true)
                                .accessibilityLabel("학과 선택")
                                .accessibilityHint("학과를 선택하려면 두 번 탭하세요")
                            }
                            .padding(.bottom, 16)
                            .onTapGesture {
                                viewStore.send(.majorTextFieldDidTap, animation: .default)
                                focusField = nil
                            }
                        }

                        if !gradeValue.isEmpty {
                            TWTextField(
                                "반",
                                text: classBinding
                            ) {
                                viewStore.send(.majorTextFieldDidTap, animation: .default)
                                focusField = nil
                            }
                            .focused($focusField, equals: .class)
                            .keyboardType(.numberPad)
                            .padding(.bottom, 16)
                            .accessibilityLabel("반 입력")
                            .accessibilityHint("숫자로 반을 입력해주세요")
                        }

                        if viewStore.selectedSchool != nil {
                            TWTextField(
                                "학년",
                                text: gradeBinding
                            ) {
                                focusField = .class
                            }
                            .focused($focusField, equals: .grade)
                            .keyboardType(.numberPad)
                            .padding(.bottom, 16)
                            .accessibilityLabel("학년 입력")
                            .accessibilityHint("숫자로 학년을 입력해주세요")
                        }
                    }

                    TWTextField(
                        "학교이름",
                        text: schoolBinding
                    ) {
                        focusField = .school
                    }
                    .focused($focusField, equals: .school)
                    .accessibilityLabel("학교 이름 입력")
                    .accessibilityHint("학교 이름을 입력하면 검색 결과가 나타납니다")

                    if isFocusedSchool {
                        if viewStore.isLoading {
                            ProgressView()
                                .progressViewStyle(.automatic)
                                .accessibilityLabel("학교 검색 중")
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewStore.schoolList, id: \.schoolCode) { school in
                                        let schoolName: String = school.name
                                        let schoolLocation: String = school.location
                                        let accessibilityText: String = "\(schoolName) \(schoolLocation)"
                                        HStack {
                                            schoolRowView(school: school)

                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background {
                                            Color.backgroundMain
                                        }
                                        .contentShape(.rect)
                                        .onTapGesture {
                                            viewStore.send(.schoolRowDidSelect(school), animation: .default)
                                            focusField = .grade
                                        }
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel(accessibilityText)
                                        .accessibilityHint("이 학교를 선택하려면 두 번 탭하세요")
                                    }
                                }
                            }
                            .accessibilityLabel("검색된 학교 목록")
                        }
                    }

                    Spacer()
                }
                .animation(.default, value: gradeValue)
                .animation(.default, value: classValue)
                .animation(.default, value: schoolValue)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .onChange(of: focusField) { newValue in
                    let isSchoolFocused: Bool = newValue == .school
                    viewStore.send(.schoolFocusedChanged(isSchoolFocused), animation: .default)
                }
                .onChange(of: gradeValue) { newValue in
                    if !newValue.isEmpty {
                        focusField = .class
                    }
                }
                VStack {
                    Spacer()

                    if showBottomButton {
                        TWButton(title: nextButtonTitle, style: .wide) {
                            viewStore.send(.nextButtonDidTap, animation: .default)
                            focusField = nil
                        }
                        .accessibilityLabel(nextButtonTitle)
                        .accessibilityHint("입력한 정보로 설정을 완료 혹은 다음 단계로 넘어갑니다")
                    }
                }
            }
            .onLoad {
                viewStore.send(.onLoad)
            }
            .onAppear {
                viewStore.send(.onAppear)
                withAnimation {
                    focusField = .school
                }
            }
            .hideKeyboardWhenTap()
            .background {
                Color.backgroundMain.ignoresSafeArea()
            }
            .twBottomSheet(
                isShowing: majorSheetBinding
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
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    func schoolRowView(school: School) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(school.name)
                .twFont(.body3, color: .textPrimary)

            Text(school.location)
                .twFont(.caption1, color: .unselectedPrimary)
        }
    }
}
