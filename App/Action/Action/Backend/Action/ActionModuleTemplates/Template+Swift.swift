//
//  ModuleTemplate+Swift.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import AuxiliaryExecute
import Cocoa

extension ActionManager {
    class ModuleTemplateSwift: ModuleTemplateExecutable {
        override func getLanguage() -> String { "Source - Swift" }
        override func getTemplateBundleName() -> String { "SourceSwift" }
        override func getBuildHint() -> String { "To build Swift Module, Xcode and it's tool xcode-build is required. Install Xcode yourself." }

        override func openDesignatedEditor(id: ActionManager.Action.ID) -> Result<Void, ActionManager.GenericActionError> {
            guard let action = ActionManager.shared[id] else {
                return .failure(GenericActionError.brokenResources)
            }
            let target = ActionManager.shared.actionModuleBaseUrl
                .appendingPathComponent(action.id.uuidString)
                .appendingPathComponent("App.xcworkspace")
            guard FileManager.default.fileExists(atPath: target.path) else {
                return .failure(GenericActionError.brokenResources)
            }
            guard NSWorkspace.shared.open(target) else {
                return .failure(GenericActionError.designatedEditorMissing)
            }
            return .success
        }

        override func compileModule(id: ActionManager.Action.ID, output: @escaping (String) -> Void) -> Result<Void, ActionManager.GenericActionError> {
            assert(!Thread.isMainThread)

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
                output("[*] starting compiler at \(temporaryDir.path)")
                try FileManager.default.createDirectory(at: temporaryDir, withIntermediateDirectories: true)
                try Executor.shared.unarchiveTar(at: getTemplateBundleURL(), toDest: temporaryDir)
                let validatedSourcePathComponents = "Source"
                let userSrc = ActionManager.shared
                    .actionModuleBaseUrl
                    .appendingPathComponent(action.id.uuidString)
                    .appendingPathComponent(validatedSourcePathComponents)
                let targetSrc = temporaryDir
                    .appendingPathComponent(validatedSourcePathComponents)
                output(
                    """
                    [*] copying user source
                        from \(userSrc.path)
                        to \(targetSrc.path)
                    """
                )
                try FileManager.default.removeItem(at: targetSrc)
                try FileManager.default.copyItem(at: userSrc, to: targetSrc)
                FileManager.default.createFile(
                    atPath: temporaryDir.appendingPathComponent(".action").path,
                    contents: nil
                )
            } catch {
                print("[E] \(error.localizedDescription)")
                return .failure(.permissionDenied)
            }

            output("[*] calling compiler script")
            let compileScript = temporaryDir
                .appendingPathComponent(".supplement")
                .appendingPathComponent("compile.sh")
            let recipe = executeBashScript(atLocation: compileScript, output: output)
            guard recipe.exitCode == 0 else {
                return .failure(.compilerError)
            }

            let binaryLocation = temporaryDir
                .appendingPathComponent(".build")
                .appendingPathComponent("cli")
            guard FileManager.default.fileExists(atPath: binaryLocation.path) else {
                return .failure(.permissionDenied)
            }

            output("[*] compiled binary at \(binaryLocation.path)")
            ActionManager.shared.registerBianry(forAction: action.id, binary: binaryLocation)
            return .success
        }

        func executeBashScript(atLocation: URL, output: @escaping (String) -> Void = { _ in }) -> AuxiliaryExecute.ExecuteRecipe {
            AuxiliaryExecute.spawn(
                command: "/bin/bash",
                args: ["-c", atLocation.path],
                output: output
            )
        }
    }
}
