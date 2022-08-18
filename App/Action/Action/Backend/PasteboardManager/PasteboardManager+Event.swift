//
//  PasteboardManager+Event.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import Foundation

extension PasteboardManager {
    struct PEvent: Codable, Equatable, Hashable {
        let content: String
        let app: AppInfo?

        init(content: String, app: PasteboardManager.AppInfo?) {
            self.content = content
            self.app = app
        }
    }

    struct AppInfo: Codable, Equatable, Hashable {
        let name: String
        let bundleIdentifier: String

        init(name: String, bundleIdentifier: String) {
            self.name = name
            self.bundleIdentifier = bundleIdentifier
        }
    }
}
