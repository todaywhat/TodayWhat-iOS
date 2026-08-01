import Combine
import Foundation

public struct TodayWhatAppRoute: Sendable, Equatable {
    public enum Kind: String, Sendable {
        case home
        case meal
        case timetable
        case mealShareBreakfast
        case mealShareLunch
        case mealShareDinner
        case timetableShare
    }

    public let kind: Kind
    public let dateString: String?

    public init(kind: Kind, date: Date? = nil) {
        self.kind = kind
        self.dateString = date.map(Self.encodeDate)
    }

    private init(kind: Kind, dateString: String?) {
        self.kind = kind
        self.dateString = dateString
    }

    public static let home = Self(kind: .home)
    public static let meal = Self(kind: .meal)
    public static let timetable = Self(kind: .timetable)

    public static func mealShare(mealType: String, date: Date? = nil) -> Self {
        switch mealType.lowercased() {
        case "breakfast":
            return Self(kind: .mealShareBreakfast, date: date)
        case "lunch":
            return Self(kind: .mealShareLunch, date: date)
        case "dinner":
            return Self(kind: .mealShareDinner, date: date)
        default:
            return Self(kind: .meal, date: date)
        }
    }

    public static func timetableShare(date: Date? = nil) -> Self {
        Self(kind: .timetableShare, date: date)
    }

    public var url: URL {
        var components = URLComponents()
        components.scheme = "todaywhat"
        components.host = kind.rawValue
        if let dateString {
            components.queryItems = [URLQueryItem(name: TodayWhatAppRouteUserInfoKey.dateString, value: dateString)]
        }
        return components.url!
    }

    public var date: Date? {
        guard let dateString else { return nil }
        return Self.decodeDate(dateString)
    }

    public var mealTypeString: String? {
        switch kind {
        case .mealShareBreakfast:
            return "breakfast"
        case .mealShareLunch:
            return "lunch"
        case .mealShareDinner:
            return "dinner"
        default:
            return nil
        }
    }

    public var isShareRoute: Bool {
        switch kind {
        case .mealShareBreakfast, .mealShareLunch, .mealShareDinner, .timetableShare:
            return true
        default:
            return false
        }
    }

    public static func from(url: URL) -> TodayWhatAppRoute? {
        guard url.scheme?.lowercased() == "todaywhat" else { return nil }

        let routeString = if let host = url.host?.lowercased(), !host.isEmpty {
            host
        } else {
            url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
        }

        guard let kind = Kind(rawValue: routeString) else { return nil }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let dateString = components?
            .queryItems?
            .first(where: { $0.name == TodayWhatAppRouteUserInfoKey.dateString })?
            .value

        return TodayWhatAppRoute(kind: kind, dateString: dateString)
    }

    public static func encodeDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    public static func decodeDate(_ string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

public enum TodayWhatAppRouteUserInfoKey {
    public static let dateString = "dateString"
    public static let mealType = "mealType"
}

public extension Notification.Name {
    static let todayWhatWidgetMealShareRequested = Notification.Name("TodayWhatWidgetMealShareRequested")
    static let todayWhatWidgetTimeTableShareRequested = Notification.Name("TodayWhatWidgetTimeTableShareRequested")
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
