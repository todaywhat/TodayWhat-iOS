import ComposableArchitecture
import TodayWhat
import XCTest

@MainActor
final class SchoolSettingCoreTests: XCTestCase {
    func testFlow_Success_SchoolSetting_Intergration() async {
        let store = TestStore(
            initialState: SchoolSettingCore.State(),
            reducer: SchoolSettingCore()
        )

        await store.send(.schoolChanged("광주소")) {
            $0.school = "광주소"
        }.finish()

        await store.send(.schoolFocusedChanged(true)) {
            $0.isFocusedSchool = true
        }.finish()

        await store.send(.schoolFocusedChanged(false)) {
            $0.isFocusedSchool = false
        }.finish()

        await store.send(.gradeChanged("1")) {
            $0.grade = "1"
        }.finish()

        await store.send(.classChanged("2")) {
            $0.class = "2"
        }.finish()

        
    }
}
