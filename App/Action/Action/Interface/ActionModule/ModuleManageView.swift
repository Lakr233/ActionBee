//
//  ModuleManageView.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

struct ModuleManageView: View {
    @ObservedObject var actionManager = ActionManager.shared

    @State var searchKey: String = ""
    @State var openCreate: Bool = false

    @State var importQueue: [URL]? = nil
    @State var importingItem: URL? = nil

    var actions: [ActionManager.Action] {
        if searchKey.isEmpty {
            return actionManager.actions
        } else {
            let key = searchKey.lowercased()
            return actionManager
                .actions
                .filter { $0.name.lowercased().contains(key) }
        }
    }

    var body: some View {
        GeometryReader { r in
            if actionManager.actions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 26, weight: .regular, design: .rounded))
                    Text("Create an action by click plus button on toolbar to process your pasteboard event. Format text, clean up links, speak when copy from special app, send to your device, etc etc. Choose an language you are familiar with to get start.")
                        .font(.system(.subheadline))
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 140))], alignment: .leading, spacing: 8) {
                        ForEach(actions, id: \.hashValue) { action in
                            ModuleElementView(id: action.id)
                        }
                    }
                    .padding(10)
                    .animation(.interactiveSpring(), value: r.size)
                    .animation(.interactiveSpring(), value: searchKey)
                }
            }
        }
        .sheet(isPresented: $openCreate) { ModuleCreateSheet() }
        .sheet(
            isPresented: Binding<Bool>(
                get: { importingItem != nil },
                set: { opened in
                    importingItem = nil
                    if !opened {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if !(importQueue?.isEmpty ?? true) {
                                importQueue?.removeFirst()
                            }
                            checkImportQueue()
                        }
                    }
                }
            )
        ) {
            ModuleImportView(url: importingItem ?? URL(fileURLWithPath: "/bad/"))
        }
        .searchable(text: $searchKey)
        .toolbar {
            ToolbarItem {
                Button {
                    openCreate = true
                } label: {
                    Label("Add Action", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            ToolbarItem {
                Button {
                    importActions()
                } label: {
                    Label("Import Action", systemImage: "square.and.arrow.down")
                }
            }
        }
        .navigationTitle("Module")
        .usePreferredContentSize()
    }

    func checkImportQueue() {
        guard let newValue = importQueue else {
            return
        }
        guard !newValue.isEmpty else {
            importQueue = nil
            importingItem = nil
            return
        }
        importingItem = newValue.first
    }

    func importActions() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.resolvesAliases = true
        panel.treatsFilePackagesAsDirectories = true
        panel.allowsMultipleSelection = true
        guard let window = NSApp.keyWindow else {
            return
        }
        panel.beginSheetModal(for: window) { resp in
            guard resp == .OK,
                  !panel.urls.isEmpty
            else {
                return
            }
            self.importQueue = panel.urls
            self.checkImportQueue()
        }
    }

    func importModule(at: URL) {
        assert(!Thread.isMainThread)
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            guard let window = NSApp.keyWindow else {
                sem.signal()
                return
            }
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "You are about to import an Action Module which is untrusted with no signature. Importing malicious modules can pose unknown risks and there is no sandbox nor container dealing with it."
            alert.informativeText = at.path
            alert.addButton(withTitle: "Trust And Import")
            alert.addButton(withTitle: "Cancel")
            alert.beginSheetModal(for: window) { resp in
                guard resp == .alertFirstButtonReturn else {
                    sem.signal()
                    return
                }
                DispatchQueue.global().async {
                    let result = actionManager.importModule(at: at)
                    if case let .failure(failure) = result {
                        print(failure.localizedDescription)
                        let sem2 = DispatchSemaphore(value: 0)
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.alertStyle = .critical
                            alert.messageText = "Failed to import this module"
                            alert.informativeText = failure.localizedDescription
                            alert.beginSheetModal(for: window) { _ in sem2.signal() }
                        }
                        sem2.wait()
                    }
                    sem.signal()
                }
            }
        }
        sem.wait()
    }
}
