//
//  ModuleCreateView.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import SwiftUI

struct ModuleCreateSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var moduleName: String = "Module - 0x\(Int.random(in: 100_000 ... 999_999))"
    @State var selectedTemplate: ActionManager.ModuleTemplateIdentifier = .swift

    @State var showProgress: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showProgress {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Label("Create Action", systemImage: "doc.badge.gearshape.fill")
                    .font(.system(.headline, design: .rounded))
                Divider()
                TextField("Module Name", text: $moduleName)
                Picker("Language", selection: $selectedTemplate) {
                    ForEach(ActionManager.ModuleTemplateIdentifier.allCases, id: \.self) { template in
                        Text(template.obtainTemplateDetails().getLanguage())
                    }
                }
                Divider()
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("Next") {
                        callCreate()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding()
        .frame(width: 300, alignment: .center)
    }

    func callCreate() {
        showProgress = true
        DispatchQueue.global().async {
            var actionId: UUID?
            defer {
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let id = actionId {
                        ActionManager.shared.initialingAciton.insert(id)
                        NotificationCenter.default.post(name: .editAction, object: id)
                    }
                }
            }
            print("[*] \(moduleName) \(selectedTemplate)")
            actionId = ActionManager.shared.createAction(
                withName: moduleName,
                withModuleTemplate: selectedTemplate
            )
        }
    }
}
