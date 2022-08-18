//
//  ModuleImportView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/18.
//

import SwiftUI

struct ModuleImportView: View {
    let url: URL

    @Environment(\.presentationMode) var presentationMode

    @State var openEdit: Bool = false
    @State var editingAction: ActionManager.Action.ID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .foregroundColor(.pink)
            Text("You are about to import an untrusted module")
                .font(.system(.headline))
                .foregroundColor(.pink)
            Text("Importing malicious module may damage your system, you are in charge to review this module.")
                .font(.system(.footnote))
                .foregroundColor(.pink)
            HStack {
                Button("Trust & Import") {
                    startImport()
                }
                .keyboardShortcut(.defaultAction)
                .tint(.pink)
                .buttonStyle(.borderedProminent)
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            Text(url.path)
                .underline()
                .font(.system(.footnote, design: .monospaced))
                .opacity(0.5)
                .onHover { if $0 { NSCursor.pointingHand.push() } else { NSCursor.pop() }}
                .onTapGesture { NSWorkspace.shared.open(url) }
        }
        .padding()
        .sheet(isPresented: $openEdit) {
            ModuleEditView(id: editingAction ?? .init())
        }
        .onChange(of: openEdit) { newValue in
            if newValue == false, editingAction != nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .frame(width: 400)
    }

    func startImport() {
        DispatchQueue.global().async {
            let result = ActionManager.shared.importModule(at: url)
            DispatchQueue.main.async {
                switch result {
                case let .success(action):
                    openEdit = true
                    editingAction = action
                case let .failure(failure):
                    guard let window = NSApp.keyWindow else {
                        presentationMode.wrappedValue.dismiss()
                        return
                    }
                    let alert = NSAlert()
                    alert.alertStyle = .critical
                    alert.messageText = failure.localizedDescription
                    alert.addButton(withTitle: "OK")
                    alert.beginSheetModal(for: window) { _ in
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
