//
//  Template+Node.swift
//  Action
//
//  Created by Innei on 2022/8/21.
//

import AuxiliaryExecute
import Foundation

extension ActionManager {
    class ModuleTemplateExecutableNode: ModuleTemplateExecutable {
        override func getLanguage() -> String { "Source - Node" }
        override func getTemplateBundleName() -> String { "SourceNode" }
        override func getBuildHint() -> String { "To build Node Module, node and it's tool is required. Install them yourself." }

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

        override func compileModule(id: ActionManager.Action.ID, output: @escaping (String) -> Void) -> Result<Void, ActionManager.GenericActionError> {
            guard let action = ActionManager.shared[id] else {
                return .failure(.brokenResources)
            }

            let temporaryDir = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
            try? FileManager.default.removeItem(at: temporaryDir)
            defer {
                try? FileManager.default.removeItem(at: temporaryDir)
            }

            do {
                output("[*] starting compiler at \(temporaryDir.path)\n")
                try FileManager.default.createDirectory(at: temporaryDir, withIntermediateDirectories: true)
                try Executor.shared.unarchiveTar(at: getTemplateBundleURL(), toDest: temporaryDir)
                let validatedSourcePathComponents = "src"
                let userSrc = ActionManager.shared
                    .actionModuleBaseUrl
                    .appendingPathComponent(action.id.uuidString)
                    .appendingPathComponent(validatedSourcePathComponents)
                let targetSrc = temporaryDir
                    .appendingPathComponent(validatedSourcePathComponents)
                output("[*] copying user source from \(userSrc.path) to \(targetSrc.path)\n")
                try FileManager.default.removeItem(at: targetSrc)
                try FileManager.default.copyItem(at: userSrc, to: targetSrc)
                FileManager.default.createFile(
                    atPath: temporaryDir.appendingPathComponent(".action").path,
                    contents: nil
                )
            } catch {
                output("[E] \(error.localizedDescription)")
                return .failure(.permissionDenied)
            }

            output("[*] calling compiler script\n")
            let compileScript = temporaryDir
                .appendingPathComponent(".supplement")
                .appendingPathComponent("compile.sh")
            let recipe = executeZshScript(atLocation: compileScript, output: output)
            guard recipe.exitCode == 0 else {
                return .failure(.compilerError)
            }

            let binaryLocation = temporaryDir
                .appendingPathComponent("dist")
                .appendingPathComponent("index.js")
            guard FileManager.default.fileExists(atPath: binaryLocation.path) else {
                return .failure(.permissionDenied)
            }

            output("[*] compiled binary at \(binaryLocation.path)\n")
            ActionManager.shared.registerBianry(forAction: action.id, binary: binaryLocation)
            return .success
        }

        override func executeModule(id: ActionManager.Action.ID, withPasteboardEvent event: PasteboardManager.PEvent, output: @escaping (String) -> Void) -> Result<ActionManager.ActionRecipeData, ActionManager.GenericActionError> {
            assert(!Thread.isMainThread)

            guard let action = ActionManager.shared[id] else {
                return .failure(.brokenResources)
            }

            let script = ActionManager.shared
                .actionBinaryBaseUrl
                .appendingPathComponent(action.id.uuidString)

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
                args: ["-c", "node \(script.path)"],
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
