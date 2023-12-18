import ProjectDescription

public extension TargetScript {
    static let swiftLint = TargetScript.pre(
        path: Path.relativeToRoot("Scripts/SwiftLintRunScript.sh"),
        name: "SwiftLint"
    )

    static let launchAtLogin = TargetScript.post(
        path: .relativeToRoot("Scripts/LaunchAtLogin.sh"),
        name: "Launch At Login Helper"
    )
}
