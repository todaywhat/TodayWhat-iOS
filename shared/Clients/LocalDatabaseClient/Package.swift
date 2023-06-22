// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocalDatabaseClient",
    platforms: [.iOS(.v15), .watchOS(.v8), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LocalDatabaseClient",
            targets: ["LocalDatabaseClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.54.1"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.3.1"),
        .package(path: "../Common/Utilities")
    ],
    targets: [
        .target(
            name: "LocalDatabaseClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "ConstantUtil", package: "Utilities"),
            ]),
        .testTarget(
            name: "LocalDatabaseClientTests",
            dependencies: ["LocalDatabaseClient"]),
    ]
)
