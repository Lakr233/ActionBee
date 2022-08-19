//
//  DomainRule.swift
//
//
//  Created by Lakr Aream on 2022/8/17.
//

import Foundation

let cleaners: [CleanerRule] = [
    Twitter(),
    BiliBili(), B23TV(),
]

protocol CleanerRule {
    func isPotentialCandidate(original url: URL) -> Bool
    func process(original url: URL) -> URL?
}

extension URL {
    func deletingAllQueryParameters() -> URL? {
        guard var components = URLComponents(
            url: self,
            resolvingAgainstBaseURL: false
        ) else {
            return nil
        }

        components.queryItems = []

        guard let newUrl = components.url else { return nil }

        var str = newUrl.absoluteString
        if str.hasSuffix("?") { str.removeLast() }

        return URL(string: str)
    }
}
