import ProjectDescription
import ConfigurationPlugin

let dependencies = Dependencies(
    carthage: nil,
    swiftPackageManager: SwiftPackageManagerDependencies(
        productTypes: [
            "GRDB": .framework
            // "ComposableArchitecture": .framework
        ],
        baseSettings: .settings(
            configurations: [
                .debug(name: .dev),
                .debug(name: .stage),
                .release(name: .prod)
            ]
        )
    ),
    platforms: [.iOS, .macOS, .watchOS]
)
