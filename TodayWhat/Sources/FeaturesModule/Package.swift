// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeaturesModule",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AllergySettingFeature",
            targets: ["AllergySettingFeature"]
        ),
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
        ),
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]
        ),
        .library(
            name: "ModifyTimeTableFeature",
            targets: ["ModifyTimeTableFeature"]
        ),
        .library(
            name: "NoticeFeature",
            targets: ["NoticeFeature"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.54.1"),
        .package(path: "../../Domains/Entity"),
        .package(path: "../../Clients/UserDefaultsClient"),
        .package(path: "../../Clients/SchoolClient"),
        .package(path: "../../Clients/MealClient"),
        .package(path: "../../Clients/TimeTableClient"),
        .package(path: "../../Clients/LocalDatabaseClient"),
        .package(path: "../../Clients/DeviceClient"),
        .package(path: "../../Clients/ITunesClient"),
        .package(path: "../../Clients/NoticeClient"),
        .package(path: "../DesignSystem"),
        .package(path: "../../Common/Utilities")
    ],
    targets: [
        .target(
            name: "RootFeature",
            dependencies: [
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
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWButton", package: "DesignSystem"),
                .product(name: "TWTextField", package: "DesignSystem"),
                .product(name: "TWBottomSheet", package: "DesignSystem"),
                "Entity",
                "NoticeClient",
                "SchoolMajorSheetFeature",
                "SchoolClient",
                "UserDefaultsClient"
            ]
        ),
        .testTarget(name: "SchoolSettingFeatureTests", dependencies: ["SchoolSettingFeature"]),
        
        .target(
            name: "SchoolMajorSheetFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWRadioButton", package: "DesignSystem"),
                .product(name: "SwiftUIUtil", package: "Utilities"),
                "LocalDatabaseClient"
            ]
        ),
        .testTarget(name: "SchoolMajorSheetFeatureTests", dependencies: ["SchoolMajorSheetFeature"]),
        
        .target(
            name: "MainFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWColor", package: "DesignSystem"),
                .product(name: "TWImage", package: "DesignSystem"),
                .product(name: "TWButton", package: "DesignSystem"),
                .product(name: "TWToast", package: "DesignSystem"),
                .product(name: "TopTabbar", package: "DesignSystem"),
                "NoticeClient",
                "UserDefaultsClient",
                "MealFeature",
                "NoticeFeature",
                "ITunesClient",
                "TimeTableFeature",
                "SettingsFeature",
                "Entity"
            ]
        ),
        .testTarget(name: "MainFeatureTests", dependencies: ["MainFeature"]),

        .target(
            name: "SplashFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserDefaultsClient"
            ]
        ),
        .testTarget(name: "SplashFeatureTests", dependencies: ["SplashFeature"]),
        
        .target(
            name: "MealFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "LabelledDivider", package: "DesignSystem"),
                .product(name: "TWButton", package: "DesignSystem"),
                .product(name: "EnumUtil", package: "Utilities"),
                "Entity",
                "MealClient",
                "LocalDatabaseClient",
                "UserDefaultsClient"
            ]
        ),
        .testTarget(name: "MealFeatureTests", dependencies: ["MealFeature"]),
        
        .target(
            name: "TimeTableFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "EnumUtil", package: "Utilities"),
                .product(name: "TWColor", package: "DesignSystem"),
                "LocalDatabaseClient",
                "Entity",
                "TimeTableClient",
                "UserDefaultsClient"
            ]
        ),
        .testTarget(name: "TimeTableFeatureTests", dependencies: ["TimeTableFeature"]),
        
        .target(
            name: "AllergySettingFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "EnumUtil", package: "Utilities"),
                .product(name: "SwiftUIUtil", package: "Utilities"),
                .product(name: "TWColor", package: "DesignSystem"),
                .product(name: "TWButton", package: "DesignSystem"),
                "LocalDatabaseClient",
                "Entity"
            ]
        ),
        .testTarget(name: "AllergySettingFeatureTests", dependencies: ["AllergySettingFeature"]),
        
        .target(
            name: "SettingsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWColor", package: "DesignSystem"),
                .product(name: "TWButton", package: "DesignSystem"),
                .product(name: "SwiftUIUtil", package: "Utilities"),
                "UserDefaultsClient",
                "ITunesClient",
                "DeviceClient",
                "SchoolSettingFeature",
                "AllergySettingFeature",
                "ModifyTimeTableFeature"
            ]
        ),

        .target(
            name: "ModifyTimeTableFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWColor", package: "DesignSystem"),
                .product(name: "TWTextField", package: "DesignSystem"),
                .product(name: "TWButton", package: "DesignSystem"),
                .product(name: "TopTabbar", package: "DesignSystem"),
                .product(name: "TWToast", package: "DesignSystem"),
                .product(name: "SwiftUIUtil", package: "Utilities"),
                .product(name: "FoundationUtil", package: "Utilities"),
                .product(name: "EnumUtil", package: "Utilities"),
                .product(name: "DateUtil", package: "Utilities"),
                "TimeTableClient",
                "Entity",
                "LocalDatabaseClient"
            ]
        ),

        .target(
            name: "NoticeFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "TWColor", package: "DesignSystem"),
                "Entity"
            ]
        )
    ]
)
