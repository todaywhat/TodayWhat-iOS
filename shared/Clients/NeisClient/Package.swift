// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NeisClient",
    platforms: [.iOS(.v15), .watchOS(.v8), .macOS(.v11)],
    products: [
        .library(
            name: "NeisClient",
            targets: ["NeisClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.54.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", exact: "5.0.1"),
        .package(path: "../Common/ErrorModule"),
        .package(path: "../Common/Utilities")
    ],
    targets: [
        .target(
            name: "NeisClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                "ErrorModule",
                .product(name: "ConstantUtil", package: "Utilities")
            ]),
        .testTarget(
            name: "NeisClientTests",
            dependencies: ["NeisClient"]),
    ]
)
