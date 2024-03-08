import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.TutorialClient.rawValue,
    targets: [
        .implements(
            module: .shared(.TutorialClient),
            dependencies: [
                .shared(target: .ComposableArchitectureWrapper),
                .shared(target: .FirebaseWrapper)
            ]
        )
    ]
)
