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
            ZStack {
                VStack(spacing: 34) {
                    if !viewStore.isFocusedSchool {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewStore.titleMessage)
                                    .twFont(.headline2, color: .extraBlack)
                                    .accessibilityLabel(viewStore.titleMessage)
                                    .accessibilityAddTraits(.isHeader)

                                if !viewStore.class.isEmpty && !viewStore.schoolMajorList.isEmpty {
                                    Text("학과는 없으면 안해도 괜찮아요!")
                                        .twFont(.body3, color: .extraBlack)
                                        .accessibilityLabel("학과 입력은 선택사항입니다")
                                }
                            }

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
                                .accessibilityLabel("학과 선택")
                                .accessibilityHint("학과를 선택하려면 두 번 탭하세요")
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
                            .accessibilityLabel("반 입력")
                            .accessibilityHint("숫자로 반을 입력해주세요")
                        }

                        if viewStore.selectedSchool != nil {
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
                            .accessibilityLabel("학년 입력")
                            .accessibilityHint("숫자로 학년을 입력해주세요")
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
                    .accessibilityLabel("학교 이름 입력")
                    .accessibilityHint("학교 이름을 입력하면 검색 결과가 나타납니다")

                    if viewStore.isFocusedSchool {
                        if viewStore.isLoading {
                            ProgressView()
                                .progressViewStyle(.automatic)
                                .accessibilityLabel("학교 검색 중")
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewStore.schoolList, id: \.schoolCode) { school in
                                        HStack {
                                            schoolRowView(school: school)

                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background {
                                            Color.backgroundMain
                                        }
                                        .onTapGesture {
                                            viewStore.send(.schoolRowDidSelect(school), animation: .default)
                                            focusField = .grade
                                        }
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel("\(school.name) \(school.location)")
                                        .accessibilityHint("이 학교를 선택하려면 두 번 탭하세요")
                                    }
                                }
                            }
                            .accessibilityLabel("검색된 학교 목록")
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
                    if !newValue.isEmpty {
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
                        .accessibilityLabel(viewStore.nextButtonTitle)
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
