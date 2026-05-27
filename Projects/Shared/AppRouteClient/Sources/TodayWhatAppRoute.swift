import Combine
import Foundation

public enum TodayWhatAppRoute: String, Sendable {
    case home
    case meal
    case timetable

    public var url: URL {
        URL(string: "todaywhat://\(rawValue)")!
    }

    public static func from(url: URL) -> TodayWhatAppRoute? {
        guard url.scheme?.lowercased() == "todaywhat" else { return nil }

        if let host = url.host?.lowercased(), let route = TodayWhatAppRoute(rawValue: host) {
            return route
        }

        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
        if let route = TodayWhatAppRoute(rawValue: path) {
            return route
        }

        return nil
    }
}

@MainActor
public final class TodayWhatAppRouteStore: ObservableObject, @unchecked Sendable {
    public static let shared = TodayWhatAppRouteStore()

    @Published public private(set) var pendingRoute: TodayWhatAppRoute?

    public var pendingRoutePublisher: Published<TodayWhatAppRoute?>.Publisher {
        $pendingRoute
    }

    public init(pendingRoute: TodayWhatAppRoute? = nil) {
        self.pendingRoute = pendingRoute
    }

    public func request(_ route: TodayWhatAppRoute) {
        pendingRoute = route
    }

    public func consumePendingRoute() -> TodayWhatAppRoute? {
        defer { pendingRoute = nil }
        return pendingRoute
    }
}
