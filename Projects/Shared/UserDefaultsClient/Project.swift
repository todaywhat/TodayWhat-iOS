import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.UserDefaultsClient.rawValue,
    targets: [
        .implements(module: .shared(.UserDefaultsClient), dependencies: [
            .SPM.ComposableArchitecture,
            .shared(target: .EnumUtil),
            .shared(target: .FoundationUtil)
        ])
    ]
)
