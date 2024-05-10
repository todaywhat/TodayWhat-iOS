import Cocoa
import Combine
import ComposableArchitecture
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
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
