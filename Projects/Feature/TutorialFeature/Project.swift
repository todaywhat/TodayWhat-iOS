import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.TutorialFeature.rawValue,
    targets: [
        .implements(module: .feature(.TutorialFeature)),
        .demo(module: .feature(.TutorialFeature), dependencies: [
            .feature(target: .TutorialFeature)
        ])
    ]
)
