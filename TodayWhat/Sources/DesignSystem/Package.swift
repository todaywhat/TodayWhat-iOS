// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v15), .watchOS(.v8), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TWColor",
            targets: ["TWColor"]
        ),
        .library(
            name: "TWButton",
            targets: ["TWButton"]
        ),
        .library(
            name: "TWTextField",
            targets: ["TWTextField"]
        ),
        .library(
            name: "TWRadioButton",
            targets: ["TWRadioButton"]
        ),
        .library(
            name: "TWBottomSheet",
            targets: ["TWBottomSheet"]
        ),
        .library(
            name: "TWImage",
            targets: ["TWImage"]
        ),
        .library(
            name: "LabelledDivider",
            targets: ["LabelledDivider"]
        ),
        .library(
            name: "TopTabbar",
            targets: ["TopTabbar"]
        )
    ],
    dependencies: [
        .package(path: "../../Common/Utilities")
    ],
    targets: [
        .target(
            name: "TWColor",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .target(
            name: "TWButton",
            dependencies: [
                "TWColor"
            ]
        ),
        .target(
            name: "TWTextField",
            dependencies: [
                "TWColor"
            ]
        ),
        .target(
            name: "TWRadioButton",
            dependencies: [
                "TWColor"
            ]
        ),
        .target(
            name: "TWBottomSheet",
            dependencies: [
                "TWColor",
                .product(name: "SwiftUIUtil", package: "Utilities")
            ]
        ),
        .target(
            name: "TWImage"
        ),
        .target(
            name: "LabelledDivider",
            dependencies: [
                "TWColor"
            ]
        ),
        .target(
            name: "TopTabbar",
            dependencies: [
                "TWColor"
            ]
        )
    ]
)
