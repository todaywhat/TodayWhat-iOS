import Dependencies
import Foundation
import XCTestDynamicOverlay
import NeisClient
import Entity
import ResponseDTO

public struct SchoolClient: Sendable {
    public var fetchSchoolList: @Sendable (_ keyword: String) async throws -> [School]
    public var fetchSchoolsMajorList: @Sendable (_ orgCode: String, _ schoolCode: String) async throws -> [String]
}

extension SchoolClient: DependencyKey {
    public static var liveValue: SchoolClient = SchoolClient(
        fetchSchoolList: { keyword in
            @Dependency(\.neisClient) var neisClient
            
            let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
            let response = try await neisClient.fetchDataOnNeis(
                "schoolInfo",
                queryItem: [
                    .init(name: "KEY", value: key),
                    .init(name: "Type", value: "json"),
                    .init(name: "pIndex", value: "1"),
                    .init(name: "pSize", value: "5"),
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
                    .init(name: "pSize", value: "30"),
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
    public static var testValue: SchoolClient = SchoolClient(
        fetchSchoolList: unimplemented("\(Self.self).fetchSchoolList"),
        fetchSchoolsMajorList: unimplemented("\(Self.self).fetchSchoolsMajorList")
    )
}

public extension DependencyValues {
    var schoolClient: SchoolClient {
        get { self[SchoolClient.self] }
        set { self[SchoolClient.self] = newValue }
    }
}
