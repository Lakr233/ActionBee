//
//  Template+Python.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/30.
//

import AuxiliaryExecute
import Foundation

extension ActionManager {
    class ModuleTemplatePython: ModuleTemplateExecutable {
        override func getLanguage() -> String { "Source - Python" }
        override func getTemplateBundleName() -> String { "SourcePython" }
        override func getBuildHint() -> String { "To build Python Module, python 3 and it's tool is required. Install them yourself." }

        override func openDesignatedEditor(id: ActionManager.Action.ID) -> Result<Void, ActionManager.GenericActionError> {
            let url = ActionManager.shared
                .actionModuleBaseUrl
                .appendingPathComponent(id.uuidString)

            let recipe = AuxiliaryExecute.spawn(
                command: "/bin/zsh",
                args: ["-c", "code \(url.path)"]
            )

            guard recipe.exitCode == 0 else {
                return .failure(.designatedEditorMissing)
            }

            return .success
        }

        override func compileModule(id: ActionManager.Action.ID, output _: @escaping (String) -> Void) -> Result<Void, ActionManager.GenericActionError> {
            guard let action = ActionManager.shared[id] else {
                return .failure(.brokenResources)
            }
            let actionUrl = ActionManager.shared
                .actionModuleBaseUrl
                .appendingPathComponent(action.id.uuidString)

            ActionManager.shared.registerArtifact(forAction: action.id, artifact: actionUrl)
            return .success
        }

        override func executeModule(id: ActionManager.Action.ID, withPasteboardEvent event: PasteboardManager.PEvent, output: @escaping (String) -> Void) -> Result<ActionManager.ActionRecipeData, ActionManager.GenericActionError> {
            assert(!Thread.isMainThread)

            guard let action = ActionManager.shared[id],
                  let artifact = ActionManager.shared.artifacts[id]
            else {
                return .failure(.brokenResources)
            }
            guard artifact.validateSignature() else {
                return .failure(.unauthorizedModificationDetected)
            }

            let script = artifact
                .obtainArtifactUrl()
                .appendingPathComponent("main.py")

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
                command: "/bin/zsh",
                args: ["-c", "python3 \(script.path)"],
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

        func executeZshScript(atLocation: URL, output: @escaping (String) -> Void = { _ in }) -> AuxiliaryExecute.ExecuteRecipe {
            AuxiliaryExecute.spawn(
                command: "/bin/zsh",
                args: ["-c", atLocation.path],
                output: output
            )
        }
    }
}
