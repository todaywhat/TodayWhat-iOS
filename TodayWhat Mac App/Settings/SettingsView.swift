import ComposableArchitecture
import Entity
import LaunchAtLogin
import SwiftUI
import TWTextField

struct SettingsView: View {
    let store: StoreOf<SettingsCore>
    @ObservedObject var viewStore: ViewStoreOf<SettingsCore>
    @FocusState var focusState: SettingsCore.FocusState?
    @Environment(\.openURL) var openURL

    init(store: StoreOf<SettingsCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                "학교",
                text: viewStore.binding(
                    get: \.schoolText,
                    send: { .setSchoolText($0) }
                )
            )
            .textFieldStyle(.roundedBorder)
            .focused($focusState, equals: .school)

            if viewStore.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            if focusState == .school, !viewStore.isLoading {
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewStore.schoolList, id: \.hashValue) { school in
                            Button {
                                viewStore.send(.schoolDidSelect(school), animation: .default)
                            } label: {
                                schoolRowView(school: school)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer()
                }
            }

            if focusState != .school, !viewStore.isLoading {
                HStack(spacing: 20) {
                    HStack {
                        Text("학년")

                        TextField(
                            "학년",
                            text: viewStore.binding(
                                get: \.gradeText,
                                send: { .setGradeText($0) }
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                        .focused($focusState, equals: .grade)
                    }

                    HStack {
                        Text("반")

                        TextField(
                            "반",
                            text: viewStore.binding(
                                get: \.classText,
                                send: { .setClassText($0) }
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                        .focused($focusState, equals: .class)
                    }
                }

                HStack {
                    Text("학과")

                    Menu {
                        ForEach(viewStore.schoolMajorList, id: \.self) { major in
                            Button {
                                viewStore.send(.majorDidSelect(major))
                            } label: {
                                Text(major.isEmpty ? "선택안함" : major)
                            }
                        }
                    } label: {
                        Text(viewStore.majorText.isEmpty ? "선택안함" : viewStore.majorText)
                    }
                }

                HStack {
                    Text("문의")

                    Link(
                        destination: URL(string: "https://github.com/baekteun/TodayWhat-iOS/issues") ?? URL(string: "https://www.google.com")!
                    ) {
                        Text("깃허브")
                    }

                    Link(
                        destination: URL(string: "mailto:baegteun@gmail.com") ?? URL(string: "https://www.google.com")!
                    ) {
                        Text("메일")
                    }
                }

                Toggle(
                    isOn: viewStore.binding(
                        get: \.isSkipWeekend,
                        send: { .setIsSkipWeekend($0) }
                    )
                ) {
                    Text("주말 스킵하기")
                }

                Toggle(
                    isOn: viewStore.binding(
                        get: \.isSkipAfterDinner,
                        send: { .setIsSkipAfterDinner($0) }
                    )
                ) {
                    Text("저녁(7시) 이후에는 내일 급식 표시")
                }

                LaunchAtLogin.Toggle {
                    Text("시작 시 자동실행")
                }

                if viewStore.isNewVersionExist {
                    Button {
                        let url = URL(string: "https://apps.apple.com/app/id1629567018") ?? URL(string: "https://google.com")!
                        openURL(url)
                    } label: {
                        Text("오늘 뭐임 New 버전이 있어요!")
                    }
                    .padding(.top, 16)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: focusState) { newValue in
            viewStore.send(.setFocusState(newValue))
        }
        .onChange(of: viewStore.focusState) { newValue in
            self.focusState = newValue
        }
        .onAppear {
            viewStore.send(.onAppear)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            store: .init(
                initialState: .init(),
                reducer: SettingsCore()
            )
        )
    }
}
