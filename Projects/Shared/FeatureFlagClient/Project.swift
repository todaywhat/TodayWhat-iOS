import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.FeatureFlagClient.rawValue,
    targets: [
        .implements(module: .shared(.FeatureFlagClient), dependencies: [
            .shared(target: .FirebaseWrapper),
            .shared(target: .ComposableArchitectureWrapper)
        ])
    ]
)
