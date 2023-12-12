import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.LocalDatabaseClient.rawValue,
    targets: [
        .implements(module: .shared(.LocalDatabaseClient), dependencies: [
            .SPM.ComposableArchitecture,
            .SPM.GRDB,
            .shared(target: .ConstantUtil)
        ])
    ]
)
