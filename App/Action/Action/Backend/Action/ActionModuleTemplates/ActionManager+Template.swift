//
//  ActionManager+ModuleTemplate.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/15.
//

import Cocoa
import Foundation

protocol ModuleTemplate {
    func getLanguage() -> String
    func getTemplateBundleName() -> String
    func getBuildHint() -> String

    func getTemplateBundleURL() -> URL

    func openDesignatedEditor(id: ActionManager.Action.ID) -> Result<Void, ActionManager.GenericActionError>
    func compileModule(
        id: ActionManager.Action.ID,
        output: @escaping (String) -> Void
    ) -> Result<Void, ActionManager.GenericActionError>
    func executeModule(
        id: ActionManager.Action.ID,
        withPasteboardEvent event: PasteboardManager.PEvent,
        output: @escaping (String) -> Void
    ) -> Result<ActionManager.ActionRecipeData, ActionManager.GenericActionError>
}

extension ModuleTemplate {
    func getTemplateBundleURL() -> URL {
        Bundle.main.url(
            forResource: getTemplateBundleName(),
            withExtension: "ActionTemplatePackage",
            subdirectory: "ActionTemplates"
        )!
    }
}

extension ActionManager {
    enum GenericActionError: Error {
        case permissionDenied
        case compilerError
        case brokenResources
        case designatedEditorMissing
        case unauthorizedModificationDetected
        case invalidResponse
        case unknown

        var message: String {
            switch self {
            case .permissionDenied: return "Permission denied for requires resources."
            case .compilerError: return "Compiler returned an error, check your source."
            case .brokenResources: return "Resources for this module was not found."
            case .designatedEditorMissing: return "The designated editor app for this module was not found, please edit it in Finder yourself."
            case .unauthorizedModificationDetected: return "The requires resource was modified by unauthorized event."
            case .invalidResponse: return "Invalid respond."
            case .unknown: return "Unknown error occurred."
            }
        }
    }

    enum ModuleTemplateIdentifier: String, Codable, CaseIterable, Hashable, Equatable {
        case executable
        case executableSwift

        case swift

        func obtainTemplateDetails() -> ModuleTemplate {
            switch self {
            case .executable: return ModuleTemplateExecutable()
            case .executableSwift: return ModuleTemplateExecutableSwift()
            case .swift: return ModuleTemplateSwift()
            }
        }
    }

    func createAction(withName name: String, withModuleTemplate template: ModuleTemplateIdentifier) -> UUID? {
        let actionUUID = UUID()
        let templateBundleUrl = template
            .obtainTemplateDetails()
            .getTemplateBundleURL()
        let extractTarget = actionModuleBaseUrl
            .appendingPathComponent(actionUUID.uuidString)

        let action = Action(id: actionUUID, name: name, template: template)

        print("[*] creating module at \(extractTarget.path)")

        do {
            try FileManager.default.createDirectory(at: extractTarget, withIntermediateDirectories: true)
            try Executor.shared.unarchiveTar(at: templateBundleUrl, toDest: extractTarget)
            try compileManifestAndSave(forAction: action)
        } catch {
            return nil
        }

        DispatchQueue.withMainAndWait {
            self.actions = (
                self.actions + [action]
            )
            .sorted { $0.name < $1.name }
            self.enabledActions.append(action.id)
        }

        return actionUUID
    }
}
