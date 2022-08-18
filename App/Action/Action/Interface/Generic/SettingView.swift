//
//  SettingView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/17.
//

import SwiftUI

struct SettingView: View {
    @StateObject var config = Config.shared
    @State var showLicense = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section {
                    Toggle("Pasteboard Deduplicate", isOn: $config.pasteboardDeduplicate)
                        .font(.subheadline)
                    Text("Pasteboard content matches previous will not generate event if on")
                        .font(.footnote)
                    Toggle("Silent Mode", isOn: $config.silentMode)
                        .font(.subheadline)
                    Text("Do not show popover after action triggered")
                        .font(.footnote)
                    Toggle("Toast Mode", isOn: $config.toastMode)
                        .font(.subheadline)
                        .disabled(config.silentMode)
                    Text("Use toast instead of popover on menubar")
                        .font(.footnote)
                        .opacity(config.silentMode ? 0.25 : 1)
                    Toggle("Reduced UI Effects", isOn: $config.reducedEffects)
                        .font(.subheadline)
                    Text("Turning off visual effects does not affect app's core functionality")
                        .font(.footnote)
                } header: {
                    Text("Application")
                        .font(.system(.headline, design: .rounded))
                } footer: {
                    Divider()
                }
                Label("EOF", systemImage: "text.append")
                    .font(.system(.caption2, design: .rounded))
            }
            .padding(10)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    NSWorkspace.shared.open(URL(string: "https://github.com/Lakr233/ActionBee")!)
                } label: {
                    Label("Get Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }
            ToolbarItem {
                Button {
                    showLicense = true
                } label: {
                    Label("License", systemImage: "flag.2.crossed")
                }
                .sheet(isPresented: $showLicense) {
                    LicenseView()
                }
            }
        }
        .navigationTitle("Setting")
        .usePreferredContentSize()
    }
}
