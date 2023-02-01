// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimeTableClient",
    platforms: [.iOS(.v15), .watchOS(.v8), .macOS(.v11)],
    products: [
        .library(
            name: "TimeTableClient",
            targets: ["TimeTableClient"]
        ),
    ],
    dependencies: [
        .package(path: "../NeisClient"),
        .package(path: "../UserDefaultsClient"),
        .package(path: "../../Domains/Entity"),
        .package(path: "../../DataMapping/DataMapping"),
        .package(path: "../Common/Utilities")
    ],
    targets: [
        .target(
            name: "TimeTableClient",
            dependencies: [
                .product(name: "ResponseDTO", package: "DataMapping"),
                .product(name: "DateUtil", package: "Utilities"),
                .product(name: "EnumUtil", package: "Utilities"),
                .product(name: "ConstantUtil", package: "Utilities"),
                "Entity",
                "NeisClient",
                "UserDefaultsClient"
            ]
        ),
        .testTarget(
            name: "TimeTableClientTests",
            dependencies: ["TimeTableClient"]
        ),
    ]
)
