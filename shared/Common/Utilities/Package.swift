// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "ConstantUtil",
            targets: ["ConstantUtil"]
        ),
        .library(
            name: "EnumUtil",
            targets: ["EnumUtil"]
        ),
        .library(
            name: "FoundationUtil",
            targets: ["FoundationUtil"]
        ),
        .library(
            name: "DateUtil",
            targets: ["DateUtil"]
        ),
        .library(
            name: "SwiftUIUtil",
            targets: ["SwiftUIUtil"]
        )
    ],
    dependencies: [],
    targets: [
        .target(name: "ConstantUtil"),
        .testTarget(name: "ConstantUtilTests"),
        
        .target(name: "EnumUtil"),
        .testTarget(name: "EnumUtilTests"),
        
        .target(name: "FoundationUtil"),
        .testTarget(name: "FoundationUtilTests"),

        .target(name: "DateUtil"),
        .testTarget(name: "DateUtilTests"),

        .target(name: "SwiftUIUtil")
    ]
)
