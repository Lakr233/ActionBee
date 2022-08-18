//
//  SidebarView.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import SwiftUI

#if DEBUG
    private let stubNavigationTarget: some View = Text("Hello World")
        .usePreferredContentSize()
#endif

struct SidebarView: View {
    var body: some View {
        List {
            Section("App") {
                NavigationLink {
                    WelcomeView()
                } label: {
                    Label("Welcome", systemImage: "sun.min.fill")
                }
            }

            Section("Action") {
                NavigationLink {
                    ModuleManageView()
                } label: {
                    Label("Module", systemImage: "tray.full")
                }
                NavigationLink {
                    HistoryView()
                } label: {
                    Label("History", systemImage: "clock")
                }
            }

            Section("Misc") {
                NavigationLink {
                    SettingView()
                } label: {
                    Label("Setting", systemImage: "gear")
                }
                NavigationLink {
                    DiagnosticLogView()
                } label: {
                    Label("Diagnostic", systemImage: "heart.text.square")
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
}
