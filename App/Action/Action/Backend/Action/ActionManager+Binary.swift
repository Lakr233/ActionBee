//
//  ActionManager+Binary.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import Foundation

extension ActionManager {
    struct ModuleBinary: Codable {
        let id: Action.ID
        let hash: String

        func obtainBinaryUrl() -> URL {
            ActionManager.shared
                .actionBinaryBaseUrl
                .appendingPathComponent(id.uuidString)
        }

        func validateHash() -> Bool {
            guard let data = try? Data(contentsOf: obtainBinaryUrl()),
                  hash == data.sha256()
            else {
                return false
            }
            return true
        }
    }
}
