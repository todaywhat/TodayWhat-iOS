import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.ITunesClient.rawValue,
    targets: [
        .implements(module: .shared(.ITunesClient), dependencies: [
            .SPM.ComposableArchitecture
        ])
    ]
)
