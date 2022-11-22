// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MealClient",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "MealClient",
            targets: ["MealClient"]),
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
            name: "MealClient",
            dependencies: [
                .product(name: "ResponseDTO", package: "DataMapping"),
                "Entity",
                "NeisClient",
                "UserDefaultsClient",
                .product(name: "DateUtil", package: "Utilities")
            ]
        ),
        .testTarget(
            name: "MealClientTests",
            dependencies: ["MealClient"]
        ),
    ]
)
