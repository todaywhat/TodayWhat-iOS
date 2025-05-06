import Entity
import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State var isPresentedOption = false
    var body: some View {
        ScrollView {
            Button {
                Task {
                    await viewModel.loadData()
                }
            } label: {
                Label {
                    Text("새로고침")
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("Main"))
            }

            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.part.display)
                        .font(.system(size: 16))

                    Text(Date(), format: .dateTime.year().month().day())
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

                Text("옵션변경")
                    .font(.system(size: 14))
                    .foregroundColor(Color("Sub"))
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("Main"))
            .cornerRadius(8)
            .onTapGesture {
                isPresentedOption.toggle()
            }

            if viewModel.part != .timeTable && viewModel.meal == nil {
                Text("등록된 정보를 찾지 못했어요 😥")
            } else if viewModel.part == .timeTable && viewModel.timeTables.isEmpty {
                let date = Date()
                if date.weekday == 7 || date.weekday == 1 {
                    Text("오늘은 주말이에요! 🛏️")
                } else {
                    Text("등록된 정보를 찾지 못했어요 😥")
                }
            }

            LazyVStack(spacing: 4) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.automatic)
                }

                if viewModel.part == .timeTable {
                    ForEach(viewModel.timeTables, id: \.hashValue) { timetable in
                        VStack(alignment: .leading) {
                            timetableView(timetable)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("Main"))
                        .cornerRadius(8)
                    }
                } else {
                    ForEach(viewModel.currentMeal, id: \.self) { meal in
                        VStack(alignment: .leading) {
                            mealView(meal)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("Main"))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            Task {
                await viewModel.loadData()
            }
        }
        .sheet(isPresented: $isPresentedOption) {
            PartSelectView(selectedPart: viewModel.part) { part in
                viewModel.part = part
            }
        }
        .navigationTitle("오늘 뭐임")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func mealView(_ meal: String) -> some View {
        Text(mealDisplay(meal: meal))
            .font(.system(size: 16))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    func timetableView(_ timetable: TimeTable) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(timetable.content)
                .font(.system(size: 14, weight: .medium))

            Text("\(timetable.perio)교시")
                .foregroundColor(Color("Sub"))
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }

    private func mealDisplay(meal: String) -> String {
        return meal.replacingOccurrences(of: "[0-9.() ]", with: "", options: [.regularExpression])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
