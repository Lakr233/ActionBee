//
//  StatusBarManager.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import Foundation

final class StatusBarManager {
    var hasWindowOpened: Bool = false

    static let shared = StatusBarManager()

    private init() {}
}
