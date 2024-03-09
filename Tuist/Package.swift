// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TodayWhatPackage",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.7.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.2"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin.git", from: "5.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.20.0"),
        .package(url: "https://github.com/kean/Nuke.git", from: "12.4.0")
    ]
)
