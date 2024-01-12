import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.NoticeClient.rawValue,
    targets: [
        .implements(
            module: .shared(.NoticeClient),
            dependencies: [
                .shared(target: .ComposableArchitectureWrapper),
                .shared(target: .FirebaseWrapper),
                .shared(target: .Entity),
                .shared(target: .DateUtil)
            ]
        )
    ]
)
