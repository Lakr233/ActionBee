//
//  WelcomeView.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import Colorful
import SwiftUI

struct WelcomeView: View {
    @State var config = Config.shared

    var version: String {
        var ret = "Version: " +
            (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            + " Build: " +
            (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
        #if DEBUG
            ret = "👾 \(ret) 👾"
        #endif
        return ret
    }

    var body: some View {
        ZStack {
            if !config.reducedEffects {
                ColorfulView(colors: [.accentColor], colorCount: 4)
                    .ignoresSafeArea()
            }
            VStack(spacing: 4) {
                Image("Avatar")
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)

                Spacer().frame(height: 16)

                Text("Welcome to Action Bee")
                    .font(.system(.headline, design: .rounded))
                Text("A programmable pasteboard action trigger.")
                    .font(.system(.body, design: .rounded))

                Spacer().frame(height: 24)
            }

            VStack {
                Spacer()
                Text(version)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .opacity(0.5)
            }
        }
        .padding()
        .navigationTitle("Action Bee")
        .usePreferredContentSize()
    }
}
