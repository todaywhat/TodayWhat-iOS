import ComposableArchitecture
import Entity
import SwiftUI
import TWColor

public struct TimeTableView: View {
    let store: StoreOf<TimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<TimeTableCore>
    
    public init(store: StoreOf<TimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        viewStore.send(.initialize, animation: .default)
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                Spacer()
                    .frame(height: 16)

                ForEach(viewStore.timeTableList, id: \.self) { timeTable in
                    timeTableRow(timeTable: timeTable)
                        .padding(.horizontal, 16)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .refreshable {
            viewStore.send(.refresh, animation: .default)
        }
    }

    @ViewBuilder
    private func timeTableRow(timeTable: TimeTable) -> some View {
        HStack(spacing: 8) {
            Text("\(timeTable.perio)교시")
                .font(.system(size: 12))
                .foregroundColor(.darkGray)

            Divider()
                .foregroundColor(.lightGray)
                .frame(height: 18)

            Text(timeTable.content)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.extraPrimary)
                .padding(.leading, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background {
            Color.veryLightGray
        }
    }
}
