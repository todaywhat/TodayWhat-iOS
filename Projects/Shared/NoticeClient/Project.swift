import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.NoticeClient.rawValue,
    targets: [
        .implements(
            module: .shared(.NoticeClient),
            dependencies: [
                .SPM.ComposableArchitecture,
                .shared(target: .FirebaseWrapper),
                .shared(target: .Entity),
                .shared(target: .DateUtil)
            ]
        )
    ]
)
