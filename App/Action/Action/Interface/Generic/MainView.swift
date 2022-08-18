//
//  ContentView.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import SwiftUI

struct MainView: View {
    @State var openArgumentsSeet: Bool = false

    var body: some View {
        NavigationView {
            SidebarView()
            WelcomeView()
        }
        .navigationTitle("Action Bee")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(
                        #selector(NSSplitViewController.toggleSidebar(_:)),
                        with: nil
                    )
                } label: {
                    Label("Toggle Sidebar", systemImage: "sidebar.leading")
                }
            }
        }
        .sheet(isPresented: $openArgumentsSeet) {
            LicenseView()
        }
        .task {
            _ = Menubar.shared
        }
        .task {
            checkRequirements()
        }
        .onChange(of: openArgumentsSeet) { newValue in
            if !newValue { checkRequirements() }
        }
    }

    func checkRequirements() {
        guard ActionApp.agreeToLicense else {
            openArgumentsSeet = true
            return
        }
    }
}
