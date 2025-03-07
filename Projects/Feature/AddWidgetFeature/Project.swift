import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.AddWidgetFeature.rawValue,
    targets: [
        .implements(module: .feature(.AddWidgetFeature), dependencies: [
            .feature(target: .BaseFeature),
            .shared(target: .ComposableArchitectureWrapper)
        ])
    ]
)
