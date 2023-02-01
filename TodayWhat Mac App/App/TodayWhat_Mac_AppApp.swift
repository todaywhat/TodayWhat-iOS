import Cocoa
import ComposableArchitecture
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: EventMonitor!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(named: "TodayWhat")
            statusButton.image?.size = .init(width: 22, height: 22)
            statusButton.action = #selector(togglePopover)
            statusButton.target = self
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 350)
        popover.behavior = .transient
        let contentViw = ContentView(
            store: Store(
                initialState: .init(),
                reducer: ContentCore()
            )
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
