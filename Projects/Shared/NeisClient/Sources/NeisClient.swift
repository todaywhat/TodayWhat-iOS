import ConstantUtil
import Dependencies
import Foundation
import SwiftyJSON
import XCTestDynamicOverlay

public struct NeisClient {
    public func fetchDataOnNeis<T: Decodable>(
        _ endPoint: String,
        queryItem: [URLQueryItem],
        key: String,
        type: T.Type
    ) async throws -> T {
        guard
            var urlComponents = URLComponents(string: Consts.neisURL + endPoint)
        else {
            throw TodayWhatError.failedToFetch
        }

        urlComponents.queryItems = queryItem
        guard let url = urlComponents.url else { throw TodayWhatError.failedToFetch }
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSON(data: data)
        guard let _ = json["RESULT"].null else {
            throw TodayWhatError.failedToFetch
        }
        var info = json[key].arrayValue
        _ = info.removeFirst()
        guard let rowJson = info.first?["row"] else { throw TodayWhatError.failedToFetch }
        let responseData = try rowJson.rawData()
        return try JSONDecoder().decode(T.self, from: responseData)
    }
}

public extension NeisClient {
    /// 저장된 표준학교코드(`SD_SCHUL_CODE`)로 현재 시도교육청코드(`ATPT_OFCDC_SC_CODE`)를 다시 조회한다.
    ///
    /// 광주·전남 교육청 통합처럼 상위 데이터 소스(NEIS)에서 교육청 코드가 바뀌면,
    /// 기존에 저장해 둔 `orgCode`로는 급식/시간표가 0건으로 내려온다.
    /// 표준학교코드는 통합과 무관하게 유지되므로, 이를 기준으로 현재 교육청 코드를 재해석해 자동 복구한다.
    func resolveOrgCode(schoolCode: String, apiKey: String?) async -> String? {
        let response = try? await fetchDataOnNeis(
            "schoolInfo",
            queryItem: [
                .init(name: "KEY", value: apiKey),
                .init(name: "Type", value: "json"),
                .init(name: "pIndex", value: "1"),
                .init(name: "pSize", value: "1"),
                .init(name: "SD_SCHUL_CODE", value: schoolCode)
            ],
            key: "schoolInfo",
            type: [OrgCodeResolveDTO].self
        )
        return response?.first?.orgCode
    }
}

private struct OrgCodeResolveDTO: Decodable {
    let orgCode: String

    enum CodingKeys: String, CodingKey {
        case orgCode = "ATPT_OFCDC_SC_CODE"
    }
}

extension NeisClient: DependencyKey {
    public static var liveValue: NeisClient = NeisClient()
}

extension NeisClient: TestDependencyKey {
    public static var testValue: NeisClient = NeisClient()
}

public extension DependencyValues {
    var neisClient: NeisClient {
        get { self[NeisClient.self] }
        set { self[NeisClient.self] = newValue }
    }
}
