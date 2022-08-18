//
//  ApplicationView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import SwiftUI

struct ApplicationView: View {
    let appId: String

    var body: some View {
        Group {
            if let url = NSWorkspace
                .shared
                .urlForApplication(withBundleIdentifier: appId),
                let bundle = Bundle(url: url)
            {
                HStack(spacing: 4) {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                        .resizable()
                        .antialiased(true)
                        .frame(width: 24, height: 24)
                        .cornerRadius(4)
                        .clipped()
                    VStack(alignment: .leading, spacing: 2) {
                        Text(bundle.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Unknown Name")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                        Text(appId)
                            .font(.system(size: 6, weight: .semibold, design: .monospaced))
                            .lineLimit(1)
                    }
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "questionmark.app.dashed")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                    Text(appId)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                }
            }
        }
        .frame(height: 26)
    }
}
