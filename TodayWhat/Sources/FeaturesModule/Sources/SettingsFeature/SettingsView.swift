import AllergySettingFeature
import ComposableArchitecture
import SwiftUI
import TWButton
import SchoolSettingFeature
import SwiftUIUtil

public struct SettingsView: View {
    let store: StoreOf<SettingsCore>
    @ObservedObject var viewStore: ViewStoreOf<SettingsCore>
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    public init(store: StoreOf<SettingsCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 12) {
                schoolSettingsView()

                VStack(spacing: 0) {
                    allergySettingsView()

                    consultingSettingsView()

                    clockSettingsView()
                }

                VStack(spacing: 0) {
                    skipWeekendView()

                    onModifiedTimeTable()

                    skipAfterDinnerView()
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background {
            Color.veryLightGray.ignoresSafeArea()
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.large)
        .background {
            navigationLinks()
        }
        .twBackButton(dismiss: dismiss)
        .confirmationDialog(store.scope(state: \.confirmationDialog), dismiss: .confirmationDialogDismissed)
        .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
    }

    @ViewBuilder
    func schoolSettingsView() -> some View {
        blockView(spacing: 12) {
            viewStore.send(.schoolBlockButtonDidTap)
        } label: {
            settingsOptionsIconView("School")

            VStack(alignment: .leading, spacing: 8) {
                Text("\(viewStore.grade)학년 \(viewStore.class)반")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.extraGray)

                Text("\(viewStore.schoolName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.darkGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func allergySettingsView() -> some View {
        blockView(corners: [.topLeft, .topRight]) {
            viewStore.send(.allergyBlockButtonDidTap)
        } label: {
            settingsOptionChevronView(icon: "AllergySetting", text: "알레르기 설정")
        }
    }

    @ViewBuilder
    func consultingSettingsView() -> some View {
        blockView(corners: []) {
            viewStore.send(.consultingButtonDidTap)
        } label: {
            settingsOptionChevronView(icon: "Consulting", text: "문의하기")
        }
    }

    @ViewBuilder
    func clockSettingsView() -> some View {
        blockView(corners: [.bottomLeft, .bottomRight]) {
            
        } label: {
            settingsOptionChevronView(icon: "WritingPencil", text: "시간표 수정")
        }
    }

    @ViewBuilder
    func skipWeekendView() -> some View {
        blockView(corners: [.topLeft, .topRight]) {
            settingsOptionToggleView(
                icon: "Calendar",
                text: "주말 스킵하기",
                isOn: viewStore.binding(
                    get: \.isSkipWeekend,
                    send: SettingsCore.Action.isSkipWeekendChanged
                )
            )
        }
    }

    @ViewBuilder
    func onModifiedTimeTable() -> some View {
        blockView(corners: [.bottomLeft, .bottomRight]) {
            settingsOptionToggleView(
                icon: "Clock",
                text: "커스텀 시간표 표시",
                isOn: viewStore.binding(
                    get: \.isOnModifiedTimeTable,
                    send: SettingsCore.Action.isOnModifiedTimeTableChagned
                )
            )
        }
    }

    @ViewBuilder
    func skipAfterDinnerView() -> some View {
        blockView(corners: [.bottomLeft, .bottomRight]) {
            settingsOptionToggleView(
                icon: "SmallMeal",
                text: "저녁(7시) 이후에는 내일 급식 표시",
                isOn: viewStore.binding(
                    get: \.isSkipAfterDinner,
                    send: SettingsCore.Action.isSkipAfterDinnerChanged
                )
            )
        }
    }

    @ViewBuilder
    func blockView(
        spacing: CGFloat = 16,
        corners: UIRectCorner = .allCorners,
        action: (() -> Void)? = nil,
        @ViewBuilder label: () -> some View
    ) -> some View {
        if let action {
            Button(action: action) {
                VStack(alignment: .leading, spacing: spacing) {
                    label()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background {
                    Color.background
                }
                .cornerRadius(16, corners: corners)
            }
        } else {
            VStack(alignment: .leading, spacing: spacing) {
                label()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background {
                Color.background
            }
            .cornerRadius(16, corners: corners)
        }
    }

    @ViewBuilder
    func settingsOptionChevronView(
        icon named: String,
        text: String
    ) -> some View {
        HStack(spacing: 8) {
            settingsOptionsIconView(named)

            growText(text: text)

            Spacer()

            chevronRightIconView()
        }
    }

    @ViewBuilder
    func settingsOptionToggleView(
        icon named: String,
        text: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 8) {
            settingsOptionsIconView(named)

            growText(text: text)

            Spacer()

            Toggle("",isOn: isOn)
                .labelsHidden()
                .tint(.extraPrimary)
        }
    }

    @ViewBuilder
    func growText(text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.extraGray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func settingsOptionsIconView(_ named: String) -> some View {
        Image(named)
            .resizable()
            .renderingMode(.template)
            .frame(width: 24, height: 24)
            .foregroundColor(.extraPrimary)
    }

    @ViewBuilder
    func chevronRightIconView() -> some View {
        Image(systemName: "chevron.right")
            .resizable()
            .frame(width: 6, height: 12)
            .foregroundColor(.extraGray)
    }

    @ViewBuilder
    func navigationLinks() -> some View {
        NavigationLink(
            isActive: viewStore.binding(
                get: \.isNavigateSchoolSetting,
                send: SettingsCore.Action.schoolSettingDismissed
            )
        ) {
            IfLetStore(
                store.scope(
                    state: \.schoolSettingCore,
                    action: SettingsCore.Action.schoolSettingCore
                )
            ) { store in
                SchoolSettingView(store: store, isNavigationPushed: true)
            }
        } label: {
            EmptyView()
        }

        NavigationLink(
            isActive: viewStore.binding(
                get: \.isNavigateAllergySetting,
                send: SettingsCore.Action.allergySettingDismissed
            )
        ) {
            IfLetStore(
                store.scope(
                    state: \.allergySettingCore,
                    action: SettingsCore.Action.allergySettingCore
                )
            ) { store in
                AllergySettingView(store: store)
            }
        } label: {
            EmptyView()
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
