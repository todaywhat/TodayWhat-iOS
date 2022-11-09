import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State var isPresentedOption = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(viewModel.part.display)
                    .font(.system(size: 16))
                
                Text("옵션변경")
                    .font(.system(size: 14))
                    .foregroundColor(Color.extraGray)
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.extraGray)
            .cornerRadius(8)
            .onTapGesture {
                isPresentedOption.toggle()
            }
            
            LazyVStack(spacing: 4) {
                if viewModel.part == .timeTable {
                    ForEach(viewModel.timeTables, id: \.hashValue) { timetable in
                        VStack(alignment: .leading) {
                            timetableView(timetable)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.extraPrimary)
                        .cornerRadius(8)
                    }
                } else {
                    ForEach(viewModel.currentMeal, id: \.self) { meal in
                        VStack(alignment: .leading) {
                            mealView(meal)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.extraPrimary)
                        .cornerRadius(8)
                    }
                }
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
        Text(meal)
            .font(.system(size: 16))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    func timetableView(_ timetable: TimeTable) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(timetable.perio)교시")
                .font(.system(size: 14))
            
            Text(timetable.content)
                .foregroundColor(.extraGray)
                .font(.system(size: 16))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
