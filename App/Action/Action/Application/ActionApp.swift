//
//  ActionApp.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import SwiftUI

@main
struct ActionApp: App {
    static let bootTime: Date = .init()

    @AppStorage("wiki.qaq.agreeToLicense")
    static var agreeToLicense: Bool = false

    static let documentDirectory: URL = {
        let availableDirectories = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)

        #if DEBUG
            return availableDirectories[0]
                .appendingPathComponent("ActionBee.Debug")
        #else
            return availableDirectories[0]
                .appendingPathComponent("ActionBee")
        #endif
    }()

    init() {
        _ = ActionApp.bootTime
        applicationSetup()
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowToolbarStyle(.unifiedCompact)
        .commands { SidebarCommands() }
        .commands { CommandGroup(replacing: CommandGroupPlacement.newItem) {} }
    }
}
