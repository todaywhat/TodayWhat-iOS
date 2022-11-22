// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeaturesModule",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RootFeature",
            targets: ["RootFeature"]
        ),
        .library(
            name: "SchoolSettingFeature",
            targets: ["SchoolSettingFeature"]
        ),
        .library(
            name: "SchoolMajorSheetFeature",
            targets: ["SchoolMajorSheetFeature"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.45.0"),
        .package(path: "../../Domains/Entity"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "RootFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SchoolSettingFeature"
            ]
        ),
        .testTarget(name: "RootFeatureTests", dependencies: ["RootFeature"]),

        .target(
            name: "SchoolSettingFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWButton", package: "DesignSystem"),
                .product(name: "TWTextField", package: "DesignSystem"),
                .product(name: "TWBottomSheet", package: "DesignSystem"),
                "Entity",
                "SchoolMajorSheetFeature"
            ]
        ),
        .testTarget(name: "SchoolSettingFeatureTests", dependencies: ["SchoolSettingFeature"]),
        
        .target(
            name: "SchoolMajorSheetFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWRadioButton", package: "DesignSystem"),
            ]
        ),
        .testTarget(name: "SchoolMajorSheetFeatureTests", dependencies: ["SchoolMajorSheetFeature"])
    ]
)
