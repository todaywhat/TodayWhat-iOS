// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TodayWhatPackage",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.6.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", exact: "5.0.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.16.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin.git", exact: "5.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "10.19.0")
    ]
)
