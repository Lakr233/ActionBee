//
//  DispatchQueue.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/15.
//

import Foundation

extension DispatchQueue {
    static func withMainAndWait(block: @escaping () -> Void) {
        assert(!Thread.isMainThread)

        guard !Thread.isMainThread else {
            block()
            return
        }

        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            block()
            sem.signal()
        }
        sem.wait()
    }
}
