import ComposableArchitecture
@testable import TodayWhat
import XCTest

@MainActor
final class SchoolMajorSheetCoreTests: XCTestCase {
    func testFlow_Success_SchoolMajorSheet_Intergration() async {
        let store = TestStore(
            initialState: SchoolMajorSheetCore.State(majorList: ["더미"]),
            reducer: SchoolMajorSheetCore()
        )
    }
}
