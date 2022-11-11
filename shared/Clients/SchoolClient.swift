import ComposableArchitecture
import Foundation
import SwiftyJSON
import XCTestDynamicOverlay

struct SchoolClient: Sendable {
    var fetchSchoolList: @Sendable (String) async throws -> [School]
}

extension SchoolClient: DependencyKey {
    static var liveValue: SchoolClient = SchoolClient(
        fetchSchoolList: { keyword in
            guard
                var urlComponents = URLComponents(string: Consts.neisURL + "schoolInfo")
            else {
                throw TodayWhatError.failedToFetch
            }
            
            urlComponents.queryItems = [
                .init(name: "KEY", value: ""),
                .init(name: "Type", value: "json"),
                .init(name: "pIndex", value: "1"),
                .init(name: "pSize", value: "10"),
                .init(name: "SCHUL_NM", value: keyword)
            ]
            guard let url = urlComponents.url else { throw TodayWhatError.failedToFetch }
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSON(data: data)
            guard let _ = json["RESULT"].null else {
                throw TodayWhatError.failedToFetch
            }
            var info = json["schoolInfo"].arrayValue
            _ = info.removeFirst()
            guard let rowJson = info.first?["row"] else { throw TodayWhatError.failedToFetch }
            let responseData = try rowJson.rawData()
            return try JSONDecoder().decode([SingleSchoolResponseDTO].self, from: responseData).map { $0.toDomain() }
        }
    )
}

extension SchoolClient: TestDependencyKey {
    static var testValue: SchoolClient = SchoolClient(
        fetchSchoolList: unimplemented("\(Self.self).fetchSchoolList")
    )
}

extension DependencyValues {
    var schoolClient: SchoolClient {
        get { self[SchoolClient.self] }
        set { self[SchoolClient.self] = newValue }
    }
}
