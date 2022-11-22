import ComposableArchitecture
@testable import SchoolSettingFeature
import ErrorModule
import Entity
import XCTest

@MainActor
final class SchoolSettingCoreTests: XCTestCase {
    func testFlow_Success_SchoolSetting_Intergration() async {
        let store = TestStore(
            initialState: SchoolSettingCore.State(),
            reducer: SchoolSettingCore()
        )
        
        let dummySchool = School(orgCode: "3", schoolCode: "2", name: "광소마고", location: "미궁", schoolType: .high)
        store.dependencies.schoolClient.fetchSchoolList = { keyword in
            if keyword == "error" {
                throw TodayWhatError.failedToFetch
            }
            return [dummySchool]
        }

        await store.send(.schoolChanged("광주소")) {
            $0.school = "광주소"
        }.finish(timeout: 1000)

        await store.receive(.schoolListResponse(.success([dummySchool]))) {
            $0.schoolList = [dummySchool]
        }

        await store.send(.schoolChanged("error")) {
            $0.school = "error"
        }.finish(timeout: 1000)

        await store.receive(.schoolListResponse(.failure(TodayWhatError.failedToFetch))) {
            $0.isError = true
            $0.errorMessage = TodayWhatError.failedToFetch.localizedDescription
        }

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
