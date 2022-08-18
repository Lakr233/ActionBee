//
//  LicenseView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/17.
//

import SwiftUI

struct LicenseView: View {
    @State var agreed = false
    @Environment(\.presentationMode) var presentationMode

    var licenseText: String {
        guard let url = Bundle.main.url(forResource: "License", withExtension: "txt"),
              let text = try? String(contentsOfFile: url.path)
        else {
            return "This app's bundle is broken, do not use it."
        }
        return text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Software License", systemImage: "flag.2.crossed")
                .font(.system(.headline, design: .rounded))
            Divider()
            ScrollView {
                Text(licenseText)
                    .font(.system(.subheadline, design: .rounded))
            }
            .frame(maxHeight: 250)
            Divider()
            HStack {
                Toggle("I understand and agree to this license.", isOn: $agreed)
                Spacer()
                Button("Done") {
                    ActionApp.agreeToLicense = agreed
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!agreed)
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .task {
            agreed = ActionApp.agreeToLicense
        }
        .onChange(of: agreed) { newValue in
            if !newValue {
                ActionApp.agreeToLicense = false
            }
        }
        .frame(width: 450, alignment: .center)
    }
}
