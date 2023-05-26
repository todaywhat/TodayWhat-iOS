import ComposableArchitecture
import SwiftUI
import SwiftUIUtil
import TWColor

struct ContentView: View {
    let store: StoreOf<ContentCore>
    @ObservedObject var viewStore: ViewStoreOf<ContentCore>
    @Environment(\.popoverOpen) var popoverOpenPublisher

    init(store: StoreOf<ContentCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ZStack {
            Button {
                viewStore.send(.refresh)
            } label: {
                EmptyView()
            }
            .hidden()
            .keyboardShortcut("r", modifiers: .command)

            VStack {
                HStack {
                    infoView()

                    optionPanelView()
                }
                .padding(20)
                .frame(maxHeight: .infinity)
            }
            .frame(width: 400, height: 350)
        }
        .onReceive(popoverOpenPublisher) { output in
            viewStore.send(.popoverOpen)
        }
    }

    @ViewBuilder
    func infoView() -> some View {
        VStack {
            if viewStore.isNotSetSchool, viewStore.selectedInfoType != .settings {
                VStack {
                    Text("설정에서 학교 설정을 하고 와주세요!")

                    Button("설정하러가기") {
                        viewStore.send(.displayInfoTypeDidSelect(.settings))
                    }
                }
            } else {
                switch viewStore.selectedInfoType {
                case .breakfast, .lunch, .dinner:
                    let meal = viewStore.selectedPartMeal ?? .init(meals: [], cal: 0)
                    MealView(
                        meal: meal.meals,
                        allergyList: viewStore.allergyList,
                        calorie: meal.cal
                    )

                case .timetable:
                    TimeTableView(timetables: viewStore.timetables)

                case .allergy:
                    IfLetStore(
                        store.scope(
                            state: \.allergyCore,
                            action: ContentCore.Action.alleryCore)
                    ) { store in
                        AllergyView(store: store)
                    }
                    
                case .settings:
                    IfLetStore(
                        store.scope(
                            state: \.settingsCore,
                            action: ContentCore.Action.settingsCore
                        )
                    ) { store in
                        SettingsView(store: store)
                    }

                default:
                    EmptyView()
                }
            }

            Spacer()
        }
        .frame(height: 310)
        .frame(maxWidth: .infinity, maxHeight: 310)
    }

    @ViewBuilder
    func optionPanelView() -> some View {
        VStack {
            ForEach(DisplayInfoType.allCases.indices, id: \.self) { index in
                let item = DisplayInfoType.allCases[index]
                let isSelected: Bool = item == viewStore.selectedInfoType
                let textForeground = isSelected ? Color.veryLightGray : .primary
                panelButtonView(
                    selectedColor: isSelected ? Color.darkGray : .extraGray,
                    text: item.display,
                    foregroundColor: textForeground,
                    shortcut: "\(index + 1)"
                ) {
                    viewStore.send(.displayInfoTypeDidSelect(item))
                }
            }
            .frame(maxHeight: .infinity)

            panelButtonView(
                selectedColor: .extraGray,
                text: "🚪 종료",
                foregroundColor: .primary,
                shortcut: "q"
            ) {
                viewStore.send(.exit)
            }
        }
        .frame(width: 120)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    func panelButtonView(
        selectedColor: Color,
        text: String,
        foregroundColor: Color,
        shortcut: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedColor)
                .frame(maxHeight: .infinity)
                .overlay(alignment: .top) {
                    HStack {
                        Text(text)
                            .foregroundColor(foregroundColor)

                        Spacer()
                    }
                    .padding(8)
                }
                .overlay(
                    HStack {
                        Spacer()

                        VStack {
                            Spacer()

                            Text("cmd + \(shortcut)")
                                .font(.caption2)
                                .foregroundColor(foregroundColor)
                        }
                        .padding(.bottom, 4)
                        .padding(.trailing, 8)
                    }
                )
        }
        .buttonStyle(.borderless)
        .keyboardShortcut(.init("\(shortcut)".first ?? "1"), modifiers: .command)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: .init(
                initialState: .init(),
                reducer: ContentCore()
            )
        )
    }
}
