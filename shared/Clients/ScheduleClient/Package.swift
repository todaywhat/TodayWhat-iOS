// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScheduleClient",
    products: [
        .library(
            name: "ScheduleClient",
            targets: ["ScheduleClient"]),
    ],
    dependencies: [
        .package(path: "../NeisClient"),
        .package(path: "../UserDefaultsClient"),
        .package(path: "../../Domains/Entity"),
        .package(path: "../../DataMapping/DataMapping")
    ],
    targets: [
        .target(
            name: "ScheduleClient",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "ScheduleClientTests",
            dependencies: ["ScheduleClient"]
        ),
    ]
)
