//
//  PasteboardManager.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import AppKit

final class PasteboardManager {
    static let shared = PasteboardManager()

    private init() {
        print("[*] setting up Pasteboard Manager")

        Thread(
            target: self,
            selector: #selector(startMonitorThread),
            object: nil
        )
        .start()
    }

    let systemPasteboard = NSPasteboard.general
    private var monitorThread: Thread?
    private var monitorRunLoop: RunLoop?

    private var accessQueue = DispatchQueue(label: "wiki.qaq.PasteboardManager.accessQueue")
    private var executeQueue = DispatchQueue(label: "wiki.qaq.PasteboardManager.executeQueue")
    private var previousPasteboardChangeCount: Int?
    private var previousPasteboardEvent: PEvent?

    var eventBlockaded: Bool = false

    @objc private func startMonitorThread() {
        monitorThread = Thread.current
        monitorRunLoop = RunLoop.current
        defer {
            self.monitorThread = nil
            self.monitorRunLoop = nil
        }
        let timer = Timer(timeInterval: 0.25, repeats: true) { _ in
            self.accessQueue.async { self.checkPasteboard() }
        }
        RunLoop.current.add(timer, forMode: .common)
        CFRunLoopRun()
    }

    func clearLastEvent() {
        print("[*] clearing previous pasteboard event")
        accessQueue.async {
            self.previousPasteboardEvent = nil
        }
    }

    func requestCheckPasteboard() {
        accessQueue.async { self.checkPasteboard() }
    }

    private func checkPasteboard() {
        guard systemPasteboard.changeCount != previousPasteboardChangeCount else {
            return
        }

        let newChangeCount = systemPasteboard.changeCount
        print("[*] NSPasteboard has changeCount \(newChangeCount) previous at \(previousPasteboardChangeCount ?? -1)")
        previousPasteboardChangeCount = newChangeCount
        guard let copied = systemPasteboard.string(forType: .string) else {
            print("[?] system pasteboard does not returns as string > ignoring")
            return
        }

        let app: AppInfo? = obtainRunningApplication()
        let event = PEvent(content: copied, app: app)
        print("[*] PasteboardEvent content len \(copied.count) from \(app?.name ?? "nil")")

        var shouldDispatchEvent = false
        if let previousEvent = previousPasteboardEvent,
           previousEvent != event || !Config.shared.pasteboardDeduplicate
        {
            shouldDispatchEvent = true
        } else {
            print("[*] event content did not change, ignore dispatch")
        }

        previousPasteboardEvent = event

        if shouldDispatchEvent { prepareWorkflow(forPasteboardEvent: event) }
    }

    private func obtainRunningApplication() -> AppInfo? {
        if let axApp = obtainRunningApplicationUsingAXElement() {
            return axApp
        }

        if let currentApplication = NSWorkspace.shared.menuBarOwningApplication,
           let name = currentApplication.localizedName,
           let bundleIdentifier = currentApplication.bundleIdentifier
        {
            return AppInfo(name: name, bundleIdentifier: bundleIdentifier)
        }

        if let currentApplication = NSWorkspace.shared.frontmostApplication,
           let name = currentApplication.localizedName,
           let bundleIdentifier = currentApplication.bundleIdentifier
        {
            return AppInfo(name: name, bundleIdentifier: bundleIdentifier)
        }

        return nil
    }

    private func obtainRunningApplicationUsingAXElement() -> AppInfo? {
        let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        guard let element = focusedElement else { return nil }
        var pid: pid_t = 0
        AXUIElementGetPid(element as! AXUIElement, &pid)
        guard pid > 0 else { return nil }
        let runningApp = NSRunningApplication(processIdentifier: pid)
        if let name = runningApp?.localizedName,
           let bundleIdentifier = runningApp?.bundleIdentifier
        {
            return AppInfo(name: name, bundleIdentifier: bundleIdentifier)
        }
        return nil
    }

    private func prepareWorkflow(forPasteboardEvent pasteboardEvent: PEvent) {
        assert(!Thread.isMainThread)
        guard !eventBlockaded else {
            print("[*] this pasteboard has been blockaded due to other process exists")
            return
        }
        PasteboardManager.shared.eventBlockaded = true
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                PasteboardManager.shared.eventBlockaded = false
            }
        }
        print("[*] calling workflow manager to resolve event")
        print("    content length \(pasteboardEvent.content.count)")
        print("    from \(pasteboardEvent.app?.bundleIdentifier ?? "unknown") (\(pasteboardEvent.app?.name ?? "nope"))")
        ActionManager.shared.handle(pasteboardEvent: pasteboardEvent)
    }
}
