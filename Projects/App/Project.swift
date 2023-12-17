import ConfigurationPlugin
import DependencyPlugin
import EnvironmentPlugin
import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let configurations: [Configuration] = generateEnvironment == .ci ?
    .default :
    [
        .debug(name: .dev, xcconfig: .relativeToXCConfig(type: .dev, name: env.name)),
        .debug(name: .stage, xcconfig: .relativeToXCConfig(type: .stage, name: env.name)),
        .release(name: .prod, xcconfig: .relativeToXCConfig(type: .prod, name: env.name))
    ]

let settings: Settings = .settings(
    base: env.baseSetting.merging(
        ["DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym"]
    ),
    configurations: configurations,
    defaultSettings: .recommended
)

let scripts: [TargetScript] = generateEnvironment.scripts

let targets: [Target] = [
    .init(
        name: env.name,
        destinations: [.iPhone, .iPad],
        product: .app,
        bundleId: "\(env.organizationName).\(env.name)",
        deploymentTargets: .iOS("15.0"),
        infoPlist: .file(path: "iOS/Support/Info.plist"),
        sources: ["iOS/Sources/**"],
        resources: ["iOS/Resources/**"],
        entitlements: .file(path: "iOS/Support/TodayWhat.entitlements"),
        scripts: scripts + [.firebaseCrashlytics],
        dependencies: [
            .feature(target: .RootFeature),
            .target(name: "\(env.name)Widget"),
            .target(name: "\(env.name)WatchApp")
        ],
        settings: settings
    ),
    .init(
        name: "\(env.name)Widget",
        destinations: [.iPhone, .iPad],
        product: .appExtension,
        bundleId: "\(env.organizationName).\(env.name).TodayWhatWidget",
        deploymentTargets: .iOS("15.0"),
        infoPlist: .file(path: "iOS-Widget/Support/Info.plist"),
        sources: ["iOS-Widget/Sources/**"],
        resources: ["iOS-Widget/Resources/**"],
        entitlements: .file(path: "iOS-Widget/Support/TodayWhatWidget.entitlements"),
        scripts: scripts,
        dependencies: [
            .SPM.ComposableArchitecture,
            .shared(target: .UserDefaultsClient),
            .shared(target: .TimeTableClient),
            .shared(target: .LocalDatabaseClient),
            .shared(target: .MealClient),
            .shared(target: .EnumUtil),
            .shared(target: .Entity),
            .shared(target: .SwiftUIUtil),
            .userInterface(target: .DesignSystem)
        ],
        settings: settings
    ),
    .init(
        name: "\(env.name)WatchApp",
        destinations: [.appleWatch],
        product: .app,
        bundleId: "\(env.organizationName).\(env.name).watchkitapp",
        deploymentTargets: .watchOS("8.0"),
        infoPlist: .file(path: "watchOS/Support/Info.plist"),
        sources: ["watchOS/Sources/**"],
        resources: ["watchOS/Resources/**"],
        scripts: scripts,
        dependencies: [
            .SPM.ComposableArchitecture,
            .shared(target: .UserDefaultsClient),
            .shared(target: .TimeTableClient),
            .shared(target: .LocalDatabaseClient),
            .shared(target: .MealClient),
            .shared(target: .EnumUtil),
            .shared(target: .Entity),
            .shared(target: .SwiftUIUtil),
            .userInterface(target: .DesignSystem)
        ],
        settings: settings
    ),
    .init(
        name: "\(env.name)-MacOS",
        destinations: [.mac],
        product: .app,
        bundleId: "\(env.organizationName).\(env.name)",
        deploymentTargets: .macOS("12.0"),
        infoPlist: .file(path: "macOS/Support/Info.plist"),
        sources: ["macOS/Sources/**"],
        resources: ["macOS/Resources/**"],
        entitlements: .file(path: "macOS/Support/TodayWhat_Mac_App.entitlements"),
        scripts: scripts,
        dependencies: [
            .SPM.ComposableArchitecture,
            .SPM.LaunchAtScreen,
            .shared(target: .Entity),
            .shared(target: .EnumUtil),
            .shared(target: .SwiftUIUtil),
            .shared(target: .TimeTableClient),
            .shared(target: .MealClient),
            .shared(target: .ITunesClient),
            .shared(target: .SchoolClient),
            .shared(target: .UserDefaultsClient),
            .shared(target: .LocalDatabaseClient),
            .userInterface(target: .DesignSystem),
            .target(name: "\(env.name)MacWidget")
        ],
        settings: settings
    ),
    .init(
        name: "\(env.name)MacWidget",
        destinations: [.mac],
        product: .appExtension,
        bundleId: "\(env.organizationName).\(env.name).TodayWhatMacWidget",
        deploymentTargets: .macOS("12.0"),
        infoPlist: .file(path: "macOS-Widget/Support/Info.plist"),
        sources: ["macOS-Widget/Sources/**"],
        resources: ["macOS-Widget/Resources/**"],
        entitlements: .file(path: "macOS-Widget/Support/TodayWhatMacWidget.entitlements"),
        scripts: scripts,
        dependencies: [
            .SPM.ComposableArchitecture,
            .shared(target: .UserDefaultsClient),
            .shared(target: .TimeTableClient),
            .shared(target: .MealClient),
            .shared(target: .LocalDatabaseClient),
            .shared(target: .DateUtil),
            .shared(target: .SwiftUIUtil),
            .shared(target: .Entity),
            .userInterface(target: .DesignSystem)
        ],
        settings: settings
    ),
]

let schemes: [Scheme] = [
    .init(
        name: "\(env.name)-DEV",
        shared: true,
        buildAction: .buildAction(targets: ["\(env.name)"]),
        runAction: .runAction(configuration: .dev),
        archiveAction: .archiveAction(configuration: .dev),
        profileAction: .profileAction(configuration: .dev),
        analyzeAction: .analyzeAction(configuration: .dev)
    ),
    .init(
        name: "\(env.name)-STAGE",
        shared: true,
        buildAction: .buildAction(targets: ["\(env.name)"]),
        runAction: .runAction(configuration: .stage),
        archiveAction: .archiveAction(configuration: .stage),
        profileAction: .profileAction(configuration: .stage),
        analyzeAction: .analyzeAction(configuration: .stage)
    ),
    .init(
        name: "\(env.name)-PROD",
        shared: true,
        buildAction: .buildAction(targets: ["\(env.name)"]),
        runAction: .runAction(configuration: .prod),
        archiveAction: .archiveAction(configuration: .prod),
        profileAction: .profileAction(configuration: .prod),
        analyzeAction: .analyzeAction(configuration: .prod)
    )
]

let project = Project(
    name: env.name,
    organizationName: env.organizationName,
    settings: settings,
    targets: targets,
    schemes: schemes
)
