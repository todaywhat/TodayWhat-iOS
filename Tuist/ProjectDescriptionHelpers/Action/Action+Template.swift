import ProjectDescription

public extension TargetScript {
    static let swiftLint = TargetScript.pre(
        path: Path.relativeToRoot("Scripts/SwiftLintRunScript.sh"),
        name: "SwiftLint",
        basedOnDependencyAnalysis: false
    )

    static let firebaseCrashlytics = TargetScript.post(
        path: .relativeToRoot("Scripts/FirebaseCrashlytics.sh"),
        name: "Firebase Crashlytics",
        inputPaths: [
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
            "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"
        ],
        basedOnDependencyAnalysis: false
    )

    static let launchAtLogin = TargetScript.post(
        path: .relativeToRoot("Scripts/LaunchAtLogin.sh"),
        name: "Launch At Login Helper"
    )

    static let firebaseInfoByConfiguration = TargetScript.post(
        script: """
            case "${CONFIGURATION}" in
              "Release" )
                cp -r "$SRCROOT/Resources/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
                ;;
              *)
                cp -r "$SRCROOT/Resources/GoogleService-QA-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
                ;;
            esac

            """,
        name: "Firebase Info copy by Configuration",
        basedOnDependencyAnalysis: false
    )
}
