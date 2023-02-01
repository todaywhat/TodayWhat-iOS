// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserDefaultsClient",
    platforms: [.iOS(.v15), .watchOS(.v8), .macOS(.v11)],
    products: [
        .library(
            name: "UserDefaultsClient",
            targets: ["UserDefaultsClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.47.0"),
        .package(path: "../Common/Utilities")
    ],
    targets: [
        .target(
            name: "UserDefaultsClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "EnumUtil", package: "Utilities"),
                .product(name: "FoundationUtil", package: "Utilities")
            ]),
        .testTarget(
            name: "UserDefaultsClientTests",
            dependencies: ["UserDefaultsClient"]),
    ]
)
