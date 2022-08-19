//
//  ModuleEditView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/15.
//

import SwiftUI
import SymbolPicker

struct ModuleEditView: View {
    let id: UUID

    @Environment(\.presentationMode) var presentationMode

    @State var editingAction: ActionManager.Action? = nil

    @State var actionEnabled: Bool = true
    @State var openSymbolPicker: Bool = false
    @State var openCompileView: Bool = false
    @State var hoverApplication: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if editingAction == nil {
                brokenModule
            } else {
                HStack {
                    Label("Edit Action", systemImage: "slider.horizontal.3")
                        .font(.system(.headline, design: .rounded))
                    Spacer()
                    Button {
                        delete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                Divider()
                basicMetaBlock
                enableForAppsBlock
                editCodeBlock
                Divider()
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("Save") {
                        finalizeEdit()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .onAppear {
            editingAction = ActionManager.shared[id]
            actionEnabled = ActionManager.shared.enabledActions.contains(id)
        }
        .opacity(openCompileView ? 0 : 1)
        .overlay(
            VStack(alignment: .leading) {
                ProgressView()
                Divider().hidden()
                Spacer().frame(height: 20)
                Text("Compiling Source")
                    .font(.headline)
                Spacer().frame(height: 6)
                RandomCodeTextView()
            }
            .opacity(openCompileView ? 1 : 0)
            .padding()
        )
        .padding()
        .animation(.interactiveSpring(), value: openCompileView)
        .frame(width: 500, alignment: .center)
    }

    var brokenModule: some View {
        VStack {
            Image(systemName: "xmark.seal.fill")
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundColor(.pink)
                .frame(width: 80, height: 80)
            Text("Broken Module")
                .font(.headline)
            Divider()
            HStack {
                Button("Delete") {
                    ActionManager.shared.deleteModule(withId: id)
                }
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    var actionIcon: String {
        guard let icon = editingAction?.icon,
              !icon.isEmpty
        else {
            return "text.append"
        }
        return icon
    }

    var basicMetaBlock: some View {
        Group {
            Toggle("Enabled", isOn: $actionEnabled)
                .font(.system(.headline, design: .rounded))
            HStack {
                Button {
                    openSymbolPicker = true
                } label: {
                    Image(systemName: actionIcon)
                }
                TextField("Name", text: Binding<String>(
                    get: {
                        editingAction?.name ?? ""
                    },
                    set: { newValue in
                        editingAction?.name = newValue
                    }
                ))
                Text("Timeout: ")
                TextField("Name", text: Binding<String>(
                    get: {
                        String(editingAction?.timeout ?? 5)
                    },
                    set: { newValue in
                        editingAction?.timeout = Int(newValue) ?? 5
                    }
                ))
                .frame(width: 26)
                Text("s")
            }
            Text("ID: \(editingAction?.id.uuidString ?? "0x4422DEADBEEF")")
                .textSelection(.enabled)
                .font(.system(.footnote, design: .monospaced))
        }
        .sheet(isPresented: $openSymbolPicker) {
            SymbolPicker(symbol: Binding<String>(
                get: {
                    actionIcon
                },
                set: { newValue in
                    editingAction?.icon = newValue
                }
            ))
        }
    }

    var enableForAppsBlock: some View {
        Group {
            HStack {
                Text("Enable In App")
                    .font(.system(.headline, design: .rounded))
                Spacer()
                Button {
                    addApp()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                        .font(.system(.headline, design: .rounded))
                }
                .buttonStyle(.plain)
            }
            if let appList = editingAction?.enabledAppList,
               !appList.isEmpty
            {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(appList, id: \.self) { appId in
                            ApplicationView(appId: appId)
                                .blur(radius: hoverApplication == appId ? 6 : 0)
                                .overlay {
                                    Button {
                                        editingAction?.enabledAppList = editingAction?
                                            .enabledAppList
                                            .filter { $0 != appId }
                                            ?? []
                                    } label: {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                            .font(.system(.headline, design: .rounded))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(4)
                                    }
                                    .buttonStyle(.plain)
                                    .opacity(hoverApplication == appId ? 1 : 0)
                                }
                                .animation(.interactiveSpring(), value: hoverApplication)
                                .onHover { hover in
                                    if hover {
                                        hoverApplication = appId
                                    } else {
                                        hoverApplication = nil
                                    }
                                }
                        }
                    }
                }
                .frame(height: 26)
            } else {
                Button {
                    addApp()
                } label: {
                    Label("Enabled for All Apps", systemImage: "app.badge.checkmark")
                        .font(.system(.subheadline, design: .rounded))
                        .frame(height: 26)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            Text("This pasteboard action will only run if copying from these apps")
                .textSelection(.enabled)
                .font(.system(.footnote))
        }
    }

    var editCodeBlock: some View {
        Group {
            Text("Coding")
                .font(.system(.headline, design: .rounded))
            HStack(spacing: 8) {
                Button("Edit Code") {
                    editModule()
                }
                .buttonStyle(.borderedProminent)
                Button("Show in Finder") {
                    showInFinder()
                }
                Button("Export") {
                    exportModule()
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Module Template: \(editingAction?.template.obtainTemplateDetails().getLanguage() ?? "Unknown")")
                Text(editingAction?.template.obtainTemplateDetails().getBuildHint() ?? "No Build Hint")
                    .underline()
                Text("You should recompile, click save, this module each time you edit it")
            }
            .textSelection(.enabled)
            .font(.system(.footnote))
        }
    }

    func finalizeEdit() {
        guard ActionManager.shared[id] != nil else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        guard let action = editingAction else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        ActionManager.shared.invalidateBinaryCache(forAction: id)
        ActionManager.shared.enabledActions = ActionManager.shared
            .enabledActions
            .filter { $0 != id }
        guard actionEnabled else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        ActionManager.shared.enabledActions += [id]
        ActionManager.shared.initialingAciton.remove(id)
        compile { result in
            switch result {
            case .success:
                ActionManager.shared[id] = action
                presentationMode.wrappedValue.dismiss()
            case let .failure(failure):
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Unable to compile this action: \(failure.message)"
                if let window = NSApp.keyWindow {
                    alert.beginSheetModal(for: window)
                } else {
                    alert.runModal()
                }
            }
        }
    }

    func delete() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Are you sure you want to delete this module? This operation can not be undone.", comment: "")
        alert.alertStyle = .critical
        alert.addButton(withTitle: NSLocalizedString("Delete", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        guard let window = NSApp.keyWindow else {
            return
        }
        alert.beginSheetModal(for: window) { resp in
            guard resp == .alertFirstButtonReturn else {
                return
            }
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.async {
                ActionManager.shared[id] = nil
            }
        }
    }

    func addApp() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = NSLocalizedString("Select Application", comment: "")
        openPanel.allowedContentTypes = [.application]
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.treatsFilePackagesAsDirectories = true
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications/")
        guard let window = NSApp.keyWindow else {
            return
        }
        openPanel.beginSheetModal(for: window) { resp in
            guard resp == .OK else {
                return
            }
            var buildId: Set<String> = []
            for id in editingAction?.enabledAppList ?? [] {
                buildId.insert(id)
            }
            for url in openPanel.urls {
                guard let bundle = Bundle(path: url.path),
                      let id = bundle.bundleIdentifier
                else {
                    continue
                }
                buildId.insert(id)
            }
            editingAction?.enabledAppList = Array(buildId).sorted()
        }
    }

    func showInFinder() {
        let url = ActionManager
            .shared
            .actionModuleBaseUrl
            .appendingPathComponent(editingAction?.id.uuidString ?? "")
        guard NSWorkspace.shared.open(url) else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = NSLocalizedString("Failed to load this module", comment: "")
            if let window = NSApp.keyWindow {
                alert.beginSheetModal(for: window)
            }
            return
        }
    }

    func editModule() {
        let result = editingAction?.template.obtainTemplateDetails()
            .openDesignatedEditor(id: id)
        if case let .failure(failure) = result {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = failure.message
            if let window = NSApp.keyWindow {
                alert.beginSheetModal(for: window)
            }
        }
    }

    func exportModule() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Module Export - \(editingAction?.name ?? "Unnamed")"
        guard let window = NSApp.keyWindow else {
            return
        }
        panel.beginSheetModal(for: window) { resp in
            guard resp == .OK,
                  let url = panel.url
            else {
                return
            }
            ActionManager.shared.updateActionModuleManifest(onActionId: id)
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.copyItem(
                at: ActionManager.shared.actionModuleBaseUrl.appendingPathComponent(id.uuidString),
                to: url
            )
        }
    }

    func compile(completion: @escaping (Result<Void, ActionManager.GenericActionError>) -> Void = { _ in }) {
        openCompileView = true
        guard let action = editingAction else {
            openCompileView = false
            completion(.failure(.brokenResources))
            return
        }
        DispatchQueue.global().async {
            let result = ActionManager.shared.issueCompile(forAction: action.id)
            DispatchQueue.main.async {
                openCompileView = false
                completion(result)
            }
        }
    }
}
