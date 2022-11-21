// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ErrorModule",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "ErrorModule",
            targets: ["ErrorModule"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ErrorModule",
            dependencies: []),
        .testTarget(
            name: "ErrorModuleTests",
            dependencies: ["ErrorModule"]),
    ]
)
