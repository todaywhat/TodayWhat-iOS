import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Feature.SettingsFeature.rawValue,
    targets: [
        .implements(module: .feature(.SettingsFeature), dependencies: [
            .feature(target: .BaseFeature),
            .feature(target: .SchoolSettingFeature),
            .feature(target: .AllergySettingFeature),
            .feature(target: .ModifyTimeTableFeature),
            .feature(target: .TutorialFeature),
            .feature(target: .AddWidgetFeature),
            .shared(target: .UserDefaultsClient),
            .shared(target: .ITunesClient),
            .shared(target: .DeviceClient)
        ])
    ]
)
