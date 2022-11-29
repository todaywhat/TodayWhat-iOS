// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataMapping",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "RequestDTO",
            targets: ["RequestDTO"]
        ),
        .library(
            name: "ResponseDTO",
            targets: ["ResponseDTO"]
        )
    ],
    dependencies: [
        .package(path: "../../Domains/Entity"),
        .package(path: "../../Common/Utilities")
    ],
    targets: [
        .target(name: "RequestDTO"),
        .testTarget(name: "RequestDTOTests"),
        .target(
            name: "ResponseDTO",
            dependencies: [
                .product(name: "Entity", package: "Entity"),
                .product(name: "EnumUtil", package: "Utilities")
            ]
        ),
        .testTarget(name: "ResponseDTOTests")
    ]
)
