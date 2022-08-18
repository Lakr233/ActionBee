//
//  ActionManager+History.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import Foundation

extension ActionManager {
    struct HistoryElement: Codable, Identifiable, Hashable, Equatable {
        var id: UUID = .init()

        let date: Date

        let event: PasteboardManager.PEvent
        let actionCandidates: [Action.ID]

        struct SuccessRecord: Codable, Identifiable, Hashable, Equatable {
            var id: UUID = .init()
            let action: Action.ID
            let recipeAction: String
            let recipeContent: String
        }

        let succeedAction: [SuccessRecord]

        struct FailureRecord: Codable, Identifiable, Hashable, Equatable {
            var id: UUID = .init()
            let action: Action.ID
            let errorHint: String
        }

        let failedAction: [FailureRecord]

        init(
            id: UUID = .init(),
            date: Date = .init(),
            event: PasteboardManager.PEvent,
            actionCandidates: [ActionManager.Action.ID] = [],
            succeedAction: [ActionManager.HistoryElement.SuccessRecord] = [],
            failedAction: [ActionManager.HistoryElement.FailureRecord] = []
        ) {
            self.id = id
            self.date = date
            self.event = event
            self.actionCandidates = actionCandidates
            self.succeedAction = succeedAction
            self.failedAction = failedAction
        }

        func search(with key: String) -> Bool {
            if event.app?.name.lowercased().contains(key) ?? false { return true }
            if event.app?.bundleIdentifier.lowercased().contains(key) ?? false { return true }
            if event.content.lowercased().contains(key) { return true }
            if date.formatted(date: .complete, time: .complete).lowercased().contains(key) {
                return true
            }
            return false
        }
    }
}
