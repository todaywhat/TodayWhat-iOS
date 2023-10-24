import AllergySettingFeature
import ComposableArchitecture
import SwiftUI
import TWButton
import SchoolSettingFeature
import SwiftUIUtil
import ModifyTimeTableFeature

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

                    timeTableSettingsView()
                }

                VStack(spacing: 0) {
                    skipAfterDinnerView()

                    onModifiedTimeTable()

                    skipWeekendView()
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
            Color.backgroundSecondary.ignoresSafeArea()
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
                    .foregroundColor(.textSecondary)

                Text("\(viewStore.schoolName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Settings Chevron
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
    func timeTableSettingsView() -> some View {
        blockView(corners: [.bottomLeft, .bottomRight]) {
            viewStore.send(.modifyTimeTableButtonDidTap)
        } label: {
            settingsOptionChevronView(icon: "WritingPencil", text: "시간표 수정")
        }
    }

    // MARK: - Settings Toggle
    @ViewBuilder
    func skipAfterDinnerView() -> some View {
        blockView(corners: [.topLeft, .topRight]) {
            settingsOptionToggleView(
                icon: "SmallMeal",
                text: "오후 7시 이후 내일 급식 표시",
                isOn: viewStore.binding(
                    get: \.isSkipAfterDinner,
                    send: SettingsCore.Action.isSkipAfterDinnerChanged
                )
            )
        }
    }

    @ViewBuilder
    func onModifiedTimeTable() -> some View {
        blockView(corners: []) {
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
    func skipWeekendView() -> some View {
        blockView(corners: [.bottomLeft, .bottomRight]) {
            settingsOptionToggleView(
                icon: "Calendar",
                text: "주말 건너뛰기",
                isOn: viewStore.binding(
                    get: \.isSkipWeekend,
                    send: SettingsCore.Action.isSkipWeekendChanged
                )
            )
        }
    }

    // MARK: - Reusable View
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
                    Color.cardBackgroundSecondary
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
                Color.cardBackgroundSecondary
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
                .tint(.textPrimary)
        }
    }

    @ViewBuilder
    func growText(text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func settingsOptionsIconView(_ named: String) -> some View {
        Image(named)
            .resizable()
            .renderingMode(.template)
            .frame(width: 24, height: 24)
            .foregroundColor(.extraBlack)
    }

    @ViewBuilder
    func chevronRightIconView() -> some View {
        Image("ChevronRight")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.unselectedPrimary)
    }

    // MARK: - Navigation Links
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

        NavigationLink(
            isActive: viewStore.binding(
                get: \.isNavigateModifyTimeTable,
                send: SettingsCore.Action.modifyTimeTableDismissed
            )
        ) {
            IfLetStore(
                store.scope(
                    state: \.modifyTimeTableCore,
                    action: SettingsCore.Action.modifyTimeTableCore
                )
            ) { store in
                ModifyTimeTableView(store: store)
            }
        } label: {
            EmptyView()
        }
    }
}
