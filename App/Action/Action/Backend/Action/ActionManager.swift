//
//  ActionManager.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import Combine
import Foundation

final class ActionManager: ObservableObject {
    static let shared = ActionManager()

    private init() {
        #if DEBUG
            for item in ModuleTemplateIdentifier.allCases {
                _ = item.obtainTemplateDetails().getTemplateBundleURL()
            }
        #endif

        var buildAction: [Action.ID: Action] = [:]
        for action in actionsStore {
            buildAction[action.id] = action
        }

        // now clean the items inside the dir if not exists in plist
        do {
            let actionIds = buildAction.keys.map(\.uuidString)
            let list = (
                try? FileManager
                    .default
                    .contentsOfDirectory(atPath: actionModuleBaseUrl.path)
            ) ?? []
            var deleteList = [String]()
            deleteList += list.filter { !actionIds.contains($0) }
            deleteList += actionIds.filter { !list.contains($0) }
            for element in deleteList {
                let url = actionModuleBaseUrl.appendingPathComponent(element)
                try? FileManager.default.removeItem(at: url)
                if let id = UUID(uuidString: element) {
                    buildAction.removeValue(forKey: id)
                }
                print("[-] removing unregistered action module file at path \(url.path)")
            }
        }

        actions = buildAction.values
            .sorted { $0.name < $1.name }
        updateActionModuleManifest()

        enabledActions = Array(Set(enabledActionsStore))

        for action in actions {
            print("[+] loading module \(action.name) - \(action.id.uuidString)")
        }

        binaries = binariesStore
        for binary in binaries {
            let found = actions.contains { $0.id == binary.key }
            if found {
                print("[+] loading binary \(binary.key.uuidString)")
            } else {
                DispatchQueue.global().async {
                    self.invalidateBinaryCache(forAction: binary.key)
                }
            }
        }

        histories = historiesStore
            .sorted { $0.date < $1.date }
    }

    var actionModuleBaseUrl: URL {
        let ret = ActionApp
            .documentDirectory
            .appendingPathComponent("ActionModules")
        try? FileManager.default.createDirectory(
            at: ret,
            withIntermediateDirectories: true
        )
        return ret
    }

    var actionBinaryBaseUrl: URL {
        let ret = ActionApp
            .documentDirectory
            .appendingPathComponent("ActionBinary")
        try? FileManager.default.createDirectory(
            at: ret,
            withIntermediateDirectories: true
        )
        return ret
    }

    let actionManifestFileName = ".ActionManifest"
    let actionManifestExtension = "plist"
    let actionManifestEncoder = PropertyListEncoder()
    let actionManifestDecoder = PropertyListDecoder()

    @EncryptedCodableDefaultsWrapper(key: "wiki.qaq.ActionManager.actionsStoreKey", defaultValue: [Action]())
    private var actionsStore

    @Published var actions: [Action] = [] {
        didSet { DispatchQueue.global().async { self.actionsStore = self.actions } }
    }

    @Published var initialingAciton: Set<Action.ID> = []

    subscript(actionId: UUID) -> Action? {
        get {
            actions.first { $0.id == actionId }
        }
        set {
            assert(Thread.isMainThread)
            guard let newValue = newValue else {
                deleteModule(withId: actionId)
                return
            }
            let idx = actions.firstIndex { $0.id == newValue.id }
            if let idx = idx {
                actions[idx] = newValue
            } else {
                actions = (
                    actions + [newValue]
                )
                .sorted { $0.name < $1.name }
            }
        }
    }

    @EncryptedCodableDefaultsWrapper(key: "wiki.qaq.ActionManager.enabledActions", defaultValue: [])
    private var enabledActionsStore: [Action.ID]

    @Published var enabledActions = [Action.ID]() {
        didSet { DispatchQueue.global().async { self.enabledActionsStore = self.enabledActions } }
    }

    @EncryptedCodableDefaultsWrapper(key: "wiki.qaq.ActionManager.binariesStore", defaultValue: [Action.ID: ModuleBinary]())
    private var binariesStore

    @Published var binaries: [Action.ID: ModuleBinary] = [:] {
        didSet { DispatchQueue.global().async { self.binariesStore = self.binaries } }
    }

    @EncryptedCodableDefaultsWrapper(key: "wiki.qaq.ActionManager.historiesStore", defaultValue: [HistoryElement]())
    private var historiesStore

    @Published var histories: [HistoryElement] = [] {
        didSet {
            let historyLimit = 500
            guard histories.count < historyLimit else {
                DispatchQueue.main.async {
                    self.histories.removeFirst(self.histories.count - historyLimit)
                }
                return
            }
            DispatchQueue.global().async { self.historiesStore = self.histories }
        }
    }

    @Published var actionRunning = false
    @Published var actionRunningHint = ""
}
