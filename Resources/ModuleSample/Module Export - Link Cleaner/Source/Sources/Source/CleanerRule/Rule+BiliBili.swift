//
//  File.swift
//
//
//  Created by Lakr Aream on 2022/8/18.
//

import Foundation

class BiliBili: CleanerRule {
    func isPotentialCandidate(original url: URL) -> Bool {
        url.host?.lowercased().contains("www.bilibili.com") ?? false
    }

    func process(original url: URL) -> URL? {
        guard url.deletingLastPathComponent().lastPathComponent == "video",
              let result = url.deletingAllQueryParameters()
        else {
            return nil
        }
        return result
    }
}

class B23TV: CleanerRule {
    func isPotentialCandidate(original url: URL) -> Bool {
        url.host?.lowercased().contains("b23.tv") ?? false
    }

    func process(original url: URL) -> URL? {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
//        comps?.scheme = "https"
        guard let requestUrl = comps?.url else {
            return nil
        }
        let sem = DispatchSemaphore(value: 0)
        var cleanResult: URL?
        DispatchQueue.global().async {
            var request = URLRequest(
                url: requestUrl,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: 6
            )
            request.addValue(
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36",
                forHTTPHeaderField: "user-agent"
            )
            URLSession.shared.dataTask(with: request) { _, resp, _ in
                defer { sem.signal() }
                guard let resp = resp as? HTTPURLResponse else {
                    return
                }
                cleanResult = resp.url?.deletingAllQueryParameters()
            }
            .resume()
        }
        sem.wait()
        return cleanResult
    }
}
