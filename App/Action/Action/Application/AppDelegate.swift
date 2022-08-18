//
//  AppDelegate.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func switchDockIconMode() {
        let windowCount = NSApp
            .windows
            .filter { self.filteringSpecialWindow($0) }
            .count
        if !StatusBarManager.shared.hasWindowOpened,
           windowCount == 0,
           !Menubar.shared.popover.isShown
        {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }

    private func filteringSpecialWindow(_ window: NSWindow) -> Bool {
        let list = ["NSStatusBarWindow", "_NSPopoverWindow"]
        for item in list {
            guard let clz = NSClassFromString(item) else { continue }
            if window.isKind(of: clz.self) { return false }
        }
        return true
    }
}
