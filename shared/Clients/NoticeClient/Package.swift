// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NoticeClient",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "NoticeClient",
            targets: ["NoticeClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.54.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.3.0"),
        .package(path: "../../Domains/Entity")
    ],
    targets: [
        .target(
            name: "NoticeClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                "Entity"
            ]
        ),
        .testTarget(
            name: "NoticeClientTests",
            dependencies: ["NoticeClient"]
        ),
    ]
)
