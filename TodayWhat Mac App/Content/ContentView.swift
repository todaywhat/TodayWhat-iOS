import ComposableArchitecture
import SwiftUI
import SwiftUIUtil
import TWColor

struct ContentView: View {
    let store: StoreOf<ContentCore>
    @ObservedObject var viewStore: ViewStoreOf<ContentCore>

    init(store: StoreOf<ContentCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            HStack {
                infoView()

                optionPanelView()
            }
            .padding(20)
            .frame(maxHeight: .infinity)
        }
        .frame(width: 400, height: 350)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    @ViewBuilder
    func infoView() -> some View {
        VStack {
            switch viewStore.selectedInfoType {
            case .breakfast, .lunch, .dinner:
                let meal = viewStore.selectedPartMeal ?? .init(meals: [], cal: 0)
                MealView(meal: meal.meals, calorie: meal.cal)

            case .timetable:
                TimeTableView(timetables: viewStore.timetables)

            case .settings:
                IfLetStore(
                    store.scope(
                        state: \.settingsCore,
                        action: ContentCore.Action.settingsCore
                    )
                ) { store in
                    SettingsView(store: store)
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func optionPanelView() -> some View {
        VStack {
            ForEach(DisplayInfoType.allCases.indices, id: \.self) { index in
                let item = DisplayInfoType.allCases[index]
                let isSelected: Bool = item == viewStore.selectedInfoType
                Button {
                    viewStore.send(.displayInfoTypeDidSelect(item), animation: .default)
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.extraPrimary : .extraGray)
                        .frame(maxHeight: .infinity)
                        .overlay(
                            HStack {
                                Text(item.display)
                                    .foregroundColor(isSelected ? Color.black : .primary)

                                Spacer()
                            }
                            .padding(8)
                        )
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.init("\(index + 1)".first ?? "1"), modifiers: .command)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 120)
        .frame(maxHeight: .infinity)
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
