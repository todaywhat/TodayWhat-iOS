// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Entity",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Entity",
            targets: ["Entity"]
        ),
    ],
    dependencies: [
        .package(path: "../Common/Utilities"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.3.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Entity",
            dependencies: [
                .product(name: "EnumUtil", package: "Utilities"),
                .product(name: "GRDB", package: "GRDB.swift")
            ]
        ),
        .testTarget(
            name: "EntityTests",
            dependencies: ["Entity"]),
    ]
)
