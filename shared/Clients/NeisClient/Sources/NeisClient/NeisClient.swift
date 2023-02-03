import Dependencies
import Foundation
import SwiftyJSON
import XCTestDynamicOverlay
import ErrorModule
import ConstantUtil

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
        let detail = url.absoluteString
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSON(data: data)
        print(json)
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
