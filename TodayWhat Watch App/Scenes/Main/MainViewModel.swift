import Combine
import Entity

final class MainViewModel: ObservableObject {
    @Published var part: DisplayInfoPart = .breakfast
    @Published var currentMeal: [String] = []
    @Published var timeTables: [TimeTable] = []
    var meal: Meal?
}
