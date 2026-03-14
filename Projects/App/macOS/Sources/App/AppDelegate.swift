import Cocoa
import Combine
import ComposableArchitecture
import Dependencies
import Entity
import EnumUtil
import Firebase
import KeychainClient
import LocalDatabaseClient
import SwiftUI
import TWLog
import UserDefaultsClient
import WidgetKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.localDatabaseClient) var localDatabaseClient
    @Dependency(\.keychainClient) var keychainClient

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: EventMonitor!
    private let popoverSubject = CurrentValueSubject<Void, Never>(())

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let statusButton = statusItem.button else {
            return
        }
        statusButton.image = NSImage(named: "BAG")
        statusButton.action = #selector(togglePopover)
        statusButton.target = self

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 350)
        popover.behavior = .transient
        let contentViw = ContentView(
            store: Store(
                initialState: .init(),
                reducer: {
                    ContentCore()
                }
            )
        ).environment(
            \.popoverOpen,
            popoverSubject
                .eraseToAnyPublisher()
        )

        popover.contentViewController = NSHostingController(rootView: contentViw)

        self.popover = popover

        eventMonitor = .init(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandle(_:))

        FirebaseApp.configure()

        initializeAnalyticsUserID()
        sendUserProperties()
        sendUserPropertyWidget()

        TWLog.event(MacOSAppLaunchedEventLog())
    }

    func applicationWillTerminate(_ notification: Notification) {}

    @objc private func togglePopover(_ sender: AnyObject) {
        if popover.isShown {
            closePopover(sender)
        } else {
            openPopover(sender)
        }
    }

    private func openPopover(_ sender: AnyObject) {
        popoverSubject.send(())
        if let statusButton = statusItem.button {
            popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .maxY)
            popover.contentViewController?.view.window?.becomeKey()
            eventMonitor.start()
        }
        TWLog.event(MacOSPopoverOpenedEventLog())
    }

    private func closePopover(_ sender: AnyObject) {
        popover.performClose(sender)
        eventMonitor.stop()
    }

    private func mouseEventHandle(_ event: NSEvent?) {
        if let event, popover.isShown {
            closePopover(event)
        }
    }
}

private extension AppDelegate {
    func initializeAnalyticsUserID() {
        if let uuid = keychainClient.getValue(.uuid), !uuid.isEmpty {
            TWLog.setUserID(id: uuid)
        } else {
            let newUUID = UUID().uuidString
            keychainClient.setValue(.uuid, newUUID)
            TWLog.setUserID(id: newUUID)
        }
    }

    func sendUserProperties() {
        if let schoolTypeRawString = userDefaultsClient.getValue(.schoolType) as? String,
           let schoolType = SchoolType(rawValue: schoolTypeRawString) {
            TWLog.setUserProperty(property: .schoolType, value: schoolType.analyticsValue)
        }

        let isSkipWeekend = userDefaultsClient.getValue(.isSkipWeekend) as? Bool ?? false
        TWLog.setUserProperty(property: .isSkipWeekend, value: isSkipWeekend)

        let isSkipAfterDinner = userDefaultsClient.getValue(.isSkipAfterDinner) as? Bool ?? true
        TWLog.setUserProperty(property: .isSkipAfterDinner, value: isSkipAfterDinner)

        TWLog.setUserProperty(property: .isCustomTimeTable, value: false)

        do {
            let allergies = try localDatabaseClient.readRecords(as: AllergyLocalEntity.self)
                .compactMap { AllergyType(rawValue: $0.allergy) ?? nil }

            if allergies.isEmpty {
                TWLog.setUserProperty(property: .allergies, value: Optional<[String]>.none)
            } else {
                TWLog.setUserProperty(
                    property: .allergies,
                    value: allergies.map(\.analyticsValue)
                )
            }
        } catch {
            TWLog.error(error)
        }
    }

    func sendUserPropertyWidget() {
        WidgetCenter.shared.getCurrentConfigurations { [weak self] widgetInfos in
            guard let self else { return }
            let widgetCount = self.userDefaultsClient.getValue(.widgetCount) as? Int ?? 0

            guard case let .success(infos) = widgetInfos, widgetCount != infos.count else { return }
            self.userDefaultsClient.setValue(.widgetCount, infos.count)

            TWLog.setUserProperty(property: .widgetCount, value: infos.count)

            let propertyString: [String] = infos
                .compactMap { info -> String? in
                    switch info.kind {
                    case "TodayWhatMealWidget":
                        return "meal_\(self.widgetFamilyToProperty(family: info.family))"
                    case "TodayWhatTimeTableWidget":
                        return "timetable_\(self.widgetFamilyToProperty(family: info.family))"
                    default:
                        return nil
                    }
                }

            TWLog.setUserProperty(property: .widget, value: propertyString)
        }
    }

    func widgetFamilyToProperty(family: WidgetFamily) -> String {
        switch family {
        case .systemSmall: return "small"
        case .systemMedium: return "medium"
        case .systemLarge: return "large"
        case .systemExtraLarge: return "extra_large"
        default: return "unknown"
        }
    }
}
