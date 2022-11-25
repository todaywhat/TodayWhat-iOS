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
        ),
        .library(
            name: "MainFeature",
            targets: ["MainFeature"]
        ),
        .library(
            name: "SplashFeature",
            targets: ["SplashFeature"]
        ),
        .library(
            name: "MealFeature",
            targets: ["MealFeature"]
        ),
        .library(
            name: "TimeTableFeature",
            targets: ["TimeTableFeature"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.47.0"),
        .package(path: "../../Domains/Entity"),
        .package(path: "../../Clients/UserDefaultsClient"),
        .package(path: "../../Clients/SchoolClient"),
        .package(path: "../../Clients/MealClient"),
        .package(path: "../../Clients/TimeTableClient"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "RootFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SchoolSettingFeature",
                "MainFeature",
                "UserDefaultsClient",
                "SplashFeature"
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
                "SchoolMajorSheetFeature",
                "SchoolClient",
                "UserDefaultsClient"
            ]
        ),
        .testTarget(name: "SchoolSettingFeatureTests", dependencies: ["SchoolSettingFeature"]),
        
        .target(
            name: "SchoolMajorSheetFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWRadioButton", package: "DesignSystem")
            ]
        ),
        .testTarget(name: "SchoolMajorSheetFeatureTests", dependencies: ["SchoolMajorSheetFeature"]),
        
        .target(
            name: "MainFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWColor", package: "DesignSystem"),
                .product(name: "TWImage", package: "DesignSystem"),
                "UserDefaultsClient",
                "MealFeature",
                "TimeTableFeature",
                "SchoolSettingFeature"
            ]
        ),
        .testTarget(name: "MainFeatureTests", dependencies: ["MainFeature"]),

        .target(
            name: "SplashFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient"
            ]
        ),
        .testTarget(name: "SplashFeatureTests", dependencies: ["SplashFeature"]),
        
        .target(
            name: "MealFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "LabelledDivider", package: "DesignSystem"),
                "Entity",
                "MealClient"
            ]
        ),
        .testTarget(name: "MealFeatureTests", dependencies: ["MealFeature"]),
        
        .target(
            name: "TimeTableFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWColor", package: "DesignSystem"),
                "Entity",
                "TimeTableClient"
            ]
        ),
        .testTarget(name: "TimeTableFeatureTests", dependencies: ["TimeTableFeature"])
    ]
)
