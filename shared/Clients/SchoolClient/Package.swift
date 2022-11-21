// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SchoolClient",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SchoolClient",
            targets: ["SchoolClient"]),
    ],
    dependencies: [
        .package(path: "../NeisClient"),
        .package(path: "../../Domains/Entity"),
        .package(path: "../../DataMapping/DataMapping")
    ],
    targets: [
        .target(
            name: "SchoolClient",
            dependencies: [
                .product(name: "ResponseDTO", package: "DataMapping"),
                "Entity",
                "NeisClient"
            ]),
        .testTarget(
            name: "SchoolClientTests",
            dependencies: ["SchoolClient"])
    ]
)
