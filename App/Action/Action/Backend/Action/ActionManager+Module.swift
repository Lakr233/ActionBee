//
//  ActionManager+Module.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import Foundation

/*

 Action will be compiled into ActionManifest.plist
 into project root dir

 so the project dir looks like: eg swift
 .
 ├── .build
 │   └── cli                        <- binary
 ├── App.xcworkspace
 └── compile.sh                     <- emit binary, called each time when compile

 // user editable

 ├── Source
 │   ├── Package.swift
 │   └── Sources
 │       └── Source
 │           └── Source.swift       <- user code

 // program granted

 ├── .ActionManifest.plist          <- exported definition of this action

 */

extension ActionManager {
    struct Action: Codable, Equatable, Hashable, Identifiable {
        var id: UUID
        var name: String
        var icon: String
        var priority: Int // lower first-er P0~
        var timeout: Int

        var template: ActionManager.ModuleTemplateIdentifier

        // will only run if copy from these apps
        var enabledAppList: [String] = []

        // keep for future usage
        var attachment: [String: String]

        init(
            id: UUID = .init(),
            name: String,
            icon: String = "text.append",
            priority: Int = 100,
            timeout: Int = 5,
            template: ActionManager.ModuleTemplateIdentifier,
            enabledAppList: [String] = [],
            attachment: [String: String] = [:]
        ) {
            self.id = id
            self.name = name
            self.icon = icon
            self.priority = priority
            self.timeout = timeout
            self.template = template
            self.enabledAppList = enabledAppList
            self.attachment = attachment
        }
    }

    func updateActionModuleManifest(onActionId: Action.ID? = nil) {
        if let id = onActionId {
            guard let action = self[id] else {
                return
            }
            try? compileManifestAndSave(forAction: action)
        }
        for action in actions {
            try? compileManifestAndSave(forAction: action)
        }
    }

    func compileManifestAndSave(forAction action: Action) throws {
        let actionModuleDir = actionModuleBaseUrl
            .appendingPathComponent(action.id.uuidString)
        let manifestUrl = actionModuleDir
            .appendingPathComponent(actionManifestFileName)
            .appendingPathExtension(actionManifestExtension)
        guard FileManager.default.fileExists(atPath: actionModuleBaseUrl.path) else {
            return
        }
        let data = try actionManifestEncoder.encode(action)
        try data.write(to: manifestUrl, options: .atomic)
    }

    func deleteModule(withId id: Action.ID) {
        print("[*] deleting module \(id)")
        let moduleUrl = actionModuleBaseUrl
            .appendingPathComponent(id.uuidString)
        try? FileManager.default.removeItem(at: moduleUrl)
        actions = actions.filter { $0.id != id }
        enabledActions = enabledActions.filter { $0 != id }
        invalidateBinaryCache(forAction: id)
    }

    func issueCompile(forAction actionId: Action.ID) -> Result<Void, GenericActionError> {
        assert(!Thread.isMainThread)
        guard let action = self[actionId] else {
            return .failure(.brokenResources)
        }
        let result = action.template
            .obtainTemplateDetails()
            .compileModule(id: actionId) { print($0) }
        return result
    }

    func registerBianry(forAction actionId: Action.ID, binary: URL) {
        print("[*] copying binary at path \(binary.path) for action \(actionId)")
        guard let sha256 = try? Data(contentsOf: binary).sha256() else {
            print("[E] failed to generate binary signature")
            return
        }
        let object = ModuleBinary(id: actionId, hash: sha256)
        try? FileManager.default.createDirectory(
            at: ActionManager.shared.actionBinaryBaseUrl,
            withIntermediateDirectories: true
        )
        do {
            try? FileManager.default.removeItem(at: object.obtainBinaryUrl())
            try FileManager.default.copyItem(at: binary, to: object.obtainBinaryUrl())
        } catch {
            print("[E] \(error.localizedDescription)")
            return
        }
        print("[*] registering binary \(actionId)")
        guard Thread.isMainThread else {
            DispatchQueue.withMainAndWait {
                self.binaries[object.id] = object
            }
            return
        }
        binaries[object.id] = object
    }

    func invalidateBinaryCache(forAction actionId: Action.ID) {
        print("[*] invalidating binary cache for \(actionId)")
        if let value = binaries[actionId] {
            try? FileManager.default.removeItem(at: value.obtainBinaryUrl())
        }
        if Thread.isMainThread {
            binaries.removeValue(forKey: actionId)
        } else {
            DispatchQueue.withMainAndWait {
                self.binaries.removeValue(forKey: actionId)
            }
        }
    }

    func importModule(at: URL) -> Result<Action.ID, Error> {
        print("[*] importing module at \(at.path)")
        let manifest = at
            .appendingPathComponent(actionManifestFileName)
            .appendingPathExtension(actionManifestExtension)
        do {
            let data = try Data(contentsOf: manifest)
            let action = try actionManifestDecoder.decode(Action.self, from: data)
            let target = actionModuleBaseUrl
                .appendingPathComponent(action.id.uuidString)
            print("[*] manifest returns id \(action.id)")
            try? FileManager.default.removeItem(at: target)
            try FileManager.default.copyItem(at: at, to: target)
            invalidateBinaryCache(forAction: action.id)
            DispatchQueue.withMainAndWait {
                self[action.id] = action
                self.enabledActions.append(action.id)
            }
            updateActionModuleManifest(onActionId: action.id)
            return .success(action.id)
        } catch {
            return .failure(error)
        }
    }
}
