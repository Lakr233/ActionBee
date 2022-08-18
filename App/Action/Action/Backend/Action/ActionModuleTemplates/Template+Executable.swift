//
//  Template+Executable.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/17.
//

import AuxiliaryExecute
import Cocoa
import Foundation

extension ActionManager {
    class ModuleTemplateExecutable: ModuleTemplate {
        func getLanguage() -> String { "Binary Executable" }
        func getTemplateBundleName() -> String { "Executable" }
        func getBuildHint() -> String { "Compile your binary, name it ActionBeeModule.exec, and put it here." }

        struct ArgumentData: Codable {
            let focusAppID: String?
            let focusAppName: String?
            let pasteboardContent: String

            init(focusAppID: String?, focusAppName: String?, pasteboardContent: String) {
                self.focusAppID = focusAppID
                self.focusAppName = focusAppName
                self.pasteboardContent = pasteboardContent
            }

            func compileBase64() -> String? {
                (try? JSONEncoder().encode(self))?.base64EncodedString()
            }
        }

        func openDesignatedEditor(id: ActionManager.Action.ID) -> Result<Void, ActionManager.GenericActionError> {
            guard let action = ActionManager.shared[id] else {
                return .failure(GenericActionError.brokenResources)
            }
            let target = ActionManager.shared.actionModuleBaseUrl
                .appendingPathComponent(action.id.uuidString)
            guard FileManager.default.fileExists(atPath: target.path) else {
                return .failure(GenericActionError.brokenResources)
            }
            guard NSWorkspace.shared.open(target) else {
                return .failure(GenericActionError.designatedEditorMissing)
            }
            return .success
        }

        func compileModule(id: ActionManager.Action.ID, output _: @escaping (String) -> Void) -> Result<Void, ActionManager.GenericActionError> {
            assert(!Thread.isMainThread)

            guard let action = ActionManager.shared[id] else {
                return .failure(.brokenResources)
            }

            let target = ActionManager.shared.actionModuleBaseUrl
                .appendingPathComponent(action.id.uuidString)
                .appendingPathComponent("ActionBeeModule.exec")

            guard FileManager.default.fileExists(atPath: target.path) else {
                return .failure(.brokenResources)
            }

            guard FileManager.default.isExecutableFile(atPath: target.path) else {
                return .failure(.permissionDenied)
            }

            ActionManager.shared.registerBianry(forAction: action.id, binary: target)
            return .success
        }

        func executeModule(id: ActionManager.Action.ID, withPasteboardEvent event: PasteboardManager.PEvent, output: @escaping (String) -> Void) -> Result<ActionManager.ActionRecipeData, ActionManager.GenericActionError> {
            assert(!Thread.isMainThread)

            guard let action = ActionManager.shared[id] else {
                return .failure(.brokenResources)
            }
            guard let binary = ActionManager.shared.binaries[id] else {
                return .failure(.brokenResources)
            }

            guard binary.validateHash() else {
                return .failure(.unauthorizedModificationDetected)
            }

            guard let argument = ArgumentData(
                focusAppID: event.app?.bundleIdentifier,
                focusAppName: event.app?.name,
                pasteboardContent: event.content
            )
            .compileBase64()
            else {
                return .failure(.brokenResources)
            }

            print("[*] executing action \(id.uuidString)")

            var resultData: ActionRecipeData?

            let recipe = AuxiliaryExecute.spawn(
                command: binary.obtainBinaryUrl().path,
                environment: ["Communicator_Message": argument],
                timeout: Double(action.timeout),
                output: output
            )

            var lastLine = recipe.stderr
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: "\n")
                .last?
                .trimmingCharacters(in: .whitespaces)
                ?? ""
            let prefix = "ActionBee-Result-Recipe://"
            if lastLine.hasPrefix(prefix) {
                lastLine.removeFirst(prefix.count)
            }
            if let base64 = Data(base64Encoded: lastLine) {
                resultData = ActionRecipeData.retrieve(withData: base64)
            }

            guard let result = resultData else {
                return .failure(.invalidResponse)
            }

            return .success(result)
        }
    }

    class ModuleTemplateExecutableSwift: ModuleTemplateExecutable {
        override func getLanguage() -> String { "Binary Executable - Swift" }
        override func getTemplateBundleName() -> String { "ExecutableSwift" }
        override func getBuildHint() -> String { "Compile your binary, name it ActionBeeModule.exec, and put it here." }
    }
}
