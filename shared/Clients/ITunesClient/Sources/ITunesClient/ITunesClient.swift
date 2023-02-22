import Dependencies
import Foundation
import XCTestDynamicOverlay

public enum Kind: String {
    case macos = "macSoftware"
    case ios = "software"

    var kind: String {
        switch self {
        case .macos:
            return "mac-software"

        case .ios:
            return "software"
        }
    }
}

public struct ITunesClient {
    public var fetchCurrentVersion: @Sendable (_ kind: Kind) async throws -> String
}

extension ITunesClient: DependencyKey {
    public static var liveValue: ITunesClient = ITunesClient(
        fetchCurrentVersion: { kind in
            guard
                let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
                let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(bundleId)&entity=\(kind.rawValue)")
            else { return "" }
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            let result = json?["results"] as? [[String: Any]]
            let filteredResult = result?
                .filter { ($0["kind"] as? String) == "\(kind.kind)" }
            return filteredResult?.first?["version"] as? String ?? ""
        }
    )
}

extension ITunesClient: TestDependencyKey {
    public static var testValue: ITunesClient = ITunesClient(
        fetchCurrentVersion: unimplemented("\(Self.self).fetchCurrentVersion")
    )
}

public extension DependencyValues {
    var iTunesClient: ITunesClient {
        get { self[ITunesClient.self] }
        set { self[ITunesClient.self] = newValue }
    }
}
