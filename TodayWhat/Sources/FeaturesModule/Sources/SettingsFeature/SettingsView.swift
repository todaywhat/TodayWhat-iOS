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
            VStack(alignment: .center, spacing: 9) {
                blockView(spacing: 8) {
                    viewStore.send(.schoolBlockButtonDidTap)
                } label: {
                    Image("School")
                        .renderingMode(.template)
                        .frame(width: 32, height: 32)
                        .foregroundColor(.extraPrimary)

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


                HStack(spacing: 9) {
                    blockView(spacing: 24) {
                        viewStore.send(.allergyBlockButtonDidTap)
                    } label: {
                        Image("AllergySetting")
                            .renderingMode(.template)
                            .frame(width: 32, height: 32)
                            .foregroundColor(.extraPrimary)

                        Text("알레르기 설정")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.extraGray)
                    }

                    blockView(spacing: 24) {
                        viewStore.send(.consultingButtonDidTap)
                    } label: {
                        Image("Consulting")
                            .renderingMode(.template)
                            .frame(width: 32, height: 32)
                            .foregroundColor(.extraPrimary)

                        Text("문의하기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.extraGray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)

                blockView(spacing: 24) {
                    Image("Calendar")
                        .renderingMode(.template)
                        .frame(width: 32, height: 32)
                        .foregroundColor(.extraPrimary)

                    HStack {
                        Text("주말 스킵하기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.extraGray)

                        Spacer()

                        Toggle(
                            "",
                            isOn: viewStore.binding(
                                get: \.isSkipWeekend,
                                send: SettingsCore.Action.isSkipWeekendChanged
                            )
                        )
                        .labelsHidden()
                        .tint(.extraPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }

                blockView(spacing: 24) {
                    Image("SmallMeal")
                        .renderingMode(.template)
                        .frame(width: 32, height: 32)
                        .foregroundColor(.extraPrimary)

                    HStack {
                        Text("저녁(7시) 이후에는 내일 급식 표시")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.extraGray)

                        Spacer()

                        Toggle(
                            "",
                            isOn: viewStore.binding(
                                get: \.isSkipAfterDinner,
                                send: SettingsCore.Action.isSkipAfterDinnerChanged
                            )
                        )
                        .labelsHidden()
                        .tint(.extraPrimary)
                    }
                    .frame(maxWidth: .infinity)
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
    func blockView(
        spacing: CGFloat = 16,
        action: (() -> Void)? = nil,
        @ViewBuilder label: () -> some View
    ) -> some View {
        if let action {
            Button(action: action) {
                VStack(alignment: .leading, spacing: spacing) {
                    label()
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .background {
                    Color.background
                }
                .cornerRadius(8)
            }
        } else {
            VStack(alignment: .leading, spacing: spacing) {
                label()
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .background {
                Color.background
            }
            .cornerRadius(8)
        }
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
