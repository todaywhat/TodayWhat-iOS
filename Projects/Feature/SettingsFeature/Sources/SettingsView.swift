import AllergySettingFeature
import ComposableArchitecture
import DesignSystem
import ModifyTimeTableFeature
import SchoolSettingFeature
import SwiftUI
import SwiftUIUtil
import TutorialFeature

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

                    timeTableSettingsView()

//                    tutorialSettingsView()

                    consultingSettingsView()
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
        .alert(store: store.scope(state: \.$alert, action: \.alert))
        .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: \.confirmationDialog))
    }

    @ViewBuilder
    func schoolSettingsView() -> some View {
        blockView(spacing: 12) {
            viewStore.send(.schoolBlockButtonDidTap)
        } label: {
            settingsOptionsIconView(.school)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(viewStore.grade)학년 \(viewStore.class)반")
                    .twFont(.caption1, color: .textSecondary)

                Text("\(viewStore.schoolName)")
                    .twFont(.body3, color: .textPrimary)
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
            settingsOptionChevronView(icon: .allergySetting, text: "알레르기 설정")
        }
    }

    @ViewBuilder
    func timeTableSettingsView() -> some View {
        blockView {
            viewStore.send(.modifyTimeTableButtonDidTap)
        } label: {
            settingsOptionChevronView(icon: .writingPencil, text: "시간표 수정")
        }
    }

    @ViewBuilder
    func tutorialSettingsView() -> some View {
        blockView {
            viewStore.send(.tutorialButtonDidTap)
        } label: {
            settingsOptionChevronView(icon: .tutorial, text: "사용법")
        }
    }

    @ViewBuilder
    func consultingSettingsView() -> some View {
        blockView(corners: [.bottomLeft, .bottomRight]) {
            viewStore.send(.consultingButtonDidTap)
        } label: {
            settingsOptionChevronView(icon: .consulting, text: "문의하기")
        }
    }

    // MARK: - Settings Toggle
    @ViewBuilder
    func skipAfterDinnerView() -> some View {
        blockView(corners: [.topLeft, .topRight]) {
            settingsOptionToggleView(
                icon: .smallMeal,
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
                icon: .clock,
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
                icon: .calendar,
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
        icon image: Image,
        text: String
    ) -> some View {
        HStack(spacing: 8) {
            settingsOptionsIconView(image)

            growText(text: text)

            Spacer()

            chevronRightIconView()
        }
    }

    @ViewBuilder
    func settingsOptionToggleView(
        icon image: Image,
        text: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 8) {
            settingsOptionsIconView(image)

            growText(text: text)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.textPrimary)
        }
    }

    @ViewBuilder
    func growText(text: String) -> some View {
        Text(text)
            .twFont(.body3, color: .extraBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func settingsOptionsIconView(_ image: Image) -> some View {
        image
            .resizable()
            .renderingMode(.template)
            .frame(width: 24, height: 24)
            .foregroundColor(.extraBlack)
    }

    @ViewBuilder
    func chevronRightIconView() -> some View {
        Image.chevronRight
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.unselectedPrimary)
    }

    // MARK: - Navigation Links
    @ViewBuilder
    func navigationLinks() -> some View {
        NavigationLinkStore(
            store.scope(state: \.$schoolSettingCore, action: \.schoolSettingCore),
            onTap: {},
            destination: { store in
                SchoolSettingView(store: store)
            },
            label: { EmptyView() }
        )
        NavigationLinkStore(
            store.scope(state: \.$allergySettingCore, action: \.allergySettingCore),
            onTap: {},
            destination: { store in
                AllergySettingView(store: store)
            },
            label: { EmptyView() }
        )
        NavigationLinkStore(
            store.scope(state: \.$modifyTimeTableCore, action: \.modifyTimeTableCore),
            onTap: {},
            destination: { store in
                ModifyTimeTableView(store: store)
            },
            label: { EmptyView() }
        )
        NavigationLinkStore(
            store.scope(state: \.$tutorialCore, action: \.tutorialCore),
            onTap: {},
            destination: { store in
                TutorialView(store: store)
            },
            label: { EmptyView() }
        )
    }
}
