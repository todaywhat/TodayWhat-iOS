import ComposableArchitecture
import Foundation
import SwiftyJSON
import XCTestDynamicOverlay

struct SchoolClient: Sendable {
    var fetchSchoolList: @Sendable (String) async throws -> [School]
    var fetchSchoolsMajorList: @Sendable (_ orgCode: String, _ schoolCode: String) async throws -> [String]
}

extension SchoolClient: DependencyKey {
    static var liveValue: SchoolClient = SchoolClient(
        fetchSchoolList: { keyword in
            @Dependency(\.neisClient) var neisClient
            
            let response = try await neisClient.fetchDataOnNeis(
                "schoolInfo",
                queryItem: [
                    .init(name: "KEY", value: ""),
                    .init(name: "Type", value: "json"),
                    .init(name: "pIndex", value: "1"),
                    .init(name: "pSize", value: "10"),
                    .init(name: "SCHUL_NM", value: keyword)
                ],
                key: "schoolInfo",
                type: [SingleSchoolResponseDTO].self
            )
            return response.map { $0.toDomain() }
        },
        fetchSchoolsMajorList: { orgCode, schoolCode in
            @Dependency(\.neisClient) var neisClient

            let response = try await neisClient.fetchDataOnNeis(
                "schoolMajorinfo",
                queryItem: [
                    .init(name: "KEY", value: ""),
                    .init(name: "Type", value: "json"),
                    .init(name: "pIndex", value: "1"),
                    .init(name: "pSize", value: "100"),
                    .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                    .init(name: "SD_SCHUL_CODE", value: schoolCode)
                ],
                key: "schoolMajorinfo",
                type: [SingleSchoolMajorResponseDTO].self
            )
            return response.map { $0.toDomain() }
        }
    )
}

extension SchoolClient: TestDependencyKey {
    static var testValue: SchoolClient = SchoolClient(
        fetchSchoolList: unimplemented("\(Self.self).fetchSchoolList"),
        fetchSchoolsMajorList: unimplemented("\(Self.self).fetchSchoolsMajorList")
    )
}

extension DependencyValues {
    var schoolClient: SchoolClient {
        get { self[SchoolClient.self] }
        set { self[SchoolClient.self] = newValue }
    }
}
