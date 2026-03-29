import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.OnboardingFeature.rawValue,
    targets: [
        .implements(module: .feature(.OnboardingFeature), dependencies: [
            .feature(target: .BaseFeature),
            .feature(target: .AddWidgetFeature),
            .shared(target: .MealClient),
            .shared(target: .TimeTableClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .Entity),
            .shared(target: .DateUtil),
            .shared(target: .TWLog)
        ])
    ]
)
