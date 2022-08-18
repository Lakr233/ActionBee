//
//  Menubar.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import Cocoa
import SwiftUI

class Menubar: ObservableObject {
    static let shared = Menubar()

    var popover: NSPopover
    var statusItem: NSStatusItem?
    var eventMonitor: EventMonitor?

    private init() {
        let statusItem = NSStatusBar
            .system
            .statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.action = #selector(togglePopover(sender:))
        self.statusItem = statusItem
        let buildPopover = NSPopover()
        popover = buildPopover
        let view = MenubarView()
        buildPopover.contentViewController = NSHostingController(rootView: view)
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler)

        statusItem.button?.title = "🎉"
        statusItem.button?.target = self
    }

    func showPopover(_: AnyObject? = nil) {
        if let statusBarButton = statusItem?.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            eventMonitor?.start()
        }
    }

    func hidePopover(_ sender: AnyObject? = nil) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    func mouseEventHandler(_ event: NSEvent?) {
        if popover.isShown, let event = event {
            hidePopover(event)
        }
    }

    @objc
    func togglePopover(sender: AnyObject) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    enum TitleType: String {
        case ready = "🎉"
        case running = "💨"
    }

    private let titleThrottle = Throttle(minimumDelay: 0.5, queue: .main)
    func switchTitle(status: TitleType) {
        titleThrottle.throttle {
            self.statusItem?.button?.title = status.rawValue
        }
    }
}

extension Menubar {
    class EventMonitor {
        private var monitor: Any?
        private let mask: NSEvent.EventTypeMask
        private let handler: (NSEvent?) -> Void

        public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
            self.mask = mask
            self.handler = handler
        }

        deinit {
            stop()
        }

        public func start() {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as! NSObject
        }

        public func stop() {
            if monitor != nil {
                NSEvent.removeMonitor(monitor!)
                monitor = nil
            }
        }
    }
}
