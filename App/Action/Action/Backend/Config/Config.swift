//
//  Config.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/17.
//

import Combine
import Foundation

class Config: ObservableObject {
    static let shared = Config()

    private init() {
        reducedEffects = reducedEffectsStore
        pasteboardDeduplicate = pasteboardDeduplicateStore
        silentMode = silentModeStore
        toastMode = toastModeStore
    }

    @UserDefaultsWrapper(key: "wiki.qaq.config.reducedEffects", defaultValue: false)
    private var reducedEffectsStore

    @Published var reducedEffects: Bool = false {
        didSet { reducedEffectsStore = reducedEffects }
    }

    @UserDefaultsWrapper(key: "wiki.qaq.config.pasteboardDeduplicate", defaultValue: true)
    private var pasteboardDeduplicateStore

    @Published var pasteboardDeduplicate: Bool = true {
        didSet { pasteboardDeduplicateStore = pasteboardDeduplicate }
    }

    @UserDefaultsWrapper(key: "wiki.qaq.config.silentMode", defaultValue: false)
    private var silentModeStore

    @Published var silentMode: Bool = true {
        didSet { silentModeStore = silentMode }
    }

    @UserDefaultsWrapper(key: "wiki.qaq.config.toastMode", defaultValue: false)
    private var toastModeStore

    @Published var toastMode: Bool = true {
        didSet { toastModeStore = toastMode }
    }
}
