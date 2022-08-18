//
//  ActionManager+Event.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import Cocoa
import Foundation

private let decoder = JSONDecoder()
private let encoder = JSONEncoder()

extension ActionManager {
    struct ActionRecipeData: Codable {
        let postAction: PostAction
        let postContent: String
        let continueQueue: Bool

        enum PostAction: String, Codable {
            case overwrite
            case speak
            case none

            func humanReadableDescription() -> String {
                switch self {
                case .overwrite: return "Overwrite Pasteboard"
                case .speak: return "Speak Message"
                case .none: return "None"
                }
            }
        }

        init(postAction: PostAction, postContent: String, continueQueue: Bool) {
            self.postAction = postAction
            self.postContent = postContent
            self.continueQueue = continueQueue
        }

        func compileBase64() -> String? {
            (try? encoder.encode(self))?.base64EncodedString()
        }

        static func retrieve(withData data: Data) -> Self? {
            try? decoder.decode(Self.self, from: data)
        }
    }

    func handle(pasteboardEvent event: PasteboardManager.PEvent) {
        assert(!Thread.isMainThread)
        var actionCandidates: [Action] = []
        DispatchQueue.withMainAndWait {
            actionCandidates = self.actions
        }
        actionCandidates = actionCandidates
            .filter { enabledActions.contains($0.id) }
            .filter { !initialingAciton.contains($0.id) }
            .filter {
                if $0.enabledAppList.isEmpty {
                    return true
                }
                guard let appBundleIdentifier = event.app?.bundleIdentifier else {
                    return false
                }
                return $0.enabledAppList.contains(appBundleIdentifier)
            }
            .sorted { a, b in
                guard a.priority == b.priority else {
                    return a.priority < b.priority
                }
                return a.name < b.name
            }
        guard !actionCandidates.isEmpty else {
            print("[-] no action candidate found, ignoring pasteboard event")
            return
        }
        print("[*] pasteboard event resolved \(actionCandidates.count) candidates")

        DispatchQueue.withMainAndWait {
            self.actionRunning = true
            self.actionRunningHint = "Resolved \(actionCandidates.count) Action Candidates"
            Menubar.shared.switchTitle(status: .running)
        }

        var successAction: [HistoryElement.SuccessRecord] = []
        var failedAction: [HistoryElement.FailureRecord] = []
        var shouldShowResultWindow = false

        defer {
            let history = HistoryElement(
                event: event,
                actionCandidates: actionCandidates.map(\.id),
                succeedAction: successAction,
                failedAction: failedAction
            )
            DispatchQueue.withMainAndWait {
                self.histories.append(history)
                self.actionRunning = false
                self.actionRunningHint = ""
                Menubar.shared.switchTitle(status: .ready)

                if shouldShowResultWindow, !Config.shared.silentMode {
                    if Config.shared.toastMode {
                        var image = "checkmark.circle.fill"
                        if !failedAction.isEmpty {
                            image = "checkmark.circle.trianglebadge.exclamationmark"
                        }
                        Toast.post(systemIcon: image, message: "ActionBee Completed")
                    } else {
                        Menubar.shared.showPopover()
                    }
                }
            }
        }

        for action in actionCandidates {
            DispatchQueue.withMainAndWait {
                self.actionRunningHint = "Executing Action - \(action.name)"
            }
            let recipe = action.template
                .obtainTemplateDetails()
                .executeModule(
                    id: action.id,
                    withPasteboardEvent: event
                ) { print($0) }
            switch recipe {
            case let .success(recipe):
                successAction.append(.init(
                    action: action.id,
                    recipeAction: recipe.postAction.humanReadableDescription(),
                    recipeContent: recipe.postContent
                ))
                resolvePostAction(recipe)
                if recipe.postAction != .none { shouldShowResultWindow = true }
                guard recipe.continueQueue else { return }
            case let .failure(failure):
                shouldShowResultWindow = true
                failedAction.append(.init(action: action.id, errorHint: failure.message))
                print("[E] error executing aciton: \(failure.message)")
                continue
            }
        }
    }

    func resolvePostAction(_ object: ActionRecipeData) {
        assert(!Thread.isMainThread)
        switch object.postAction {
        case .none: break
        case .speak:
            DispatchQueue.global().async {
                Executor.shared.speak(object.postContent)
            }
        case .overwrite:
            NSPasteboard.general.prepareForNewContents()
            NSPasteboard.general.setString(object.postContent, forType: .string)
        }
    }
}
