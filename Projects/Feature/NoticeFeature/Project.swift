import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.NoticeFeature.rawValue,
    targets: [
        .implements(module: .feature(.NoticeFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .NoticeClient),
            .shared(target: .Entity)
        ])
    ]
)
