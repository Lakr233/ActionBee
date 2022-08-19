//
//  CleanerRule+Twitter.swift
//
//
//  Created by Lakr Aream on 2022/8/17.
//

import Foundation

class Twitter: CleanerRule {
    func isPotentialCandidate(original url: URL) -> Bool {
        url.host?.lowercased().contains("twitter.com") ?? false
    }

    func process(original url: URL) -> URL? {
        guard url.deletingLastPathComponent().lastPathComponent == "status",
              let result = url.deletingAllQueryParameters()
        else {
            return nil
        }
        return result
    }
}
