//
//  DiagnosticLogView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/15.
//

import SwiftUI

class Logger: ObservableObject {
    fileprivate static let shared = Logger()

    private let logCountLimitation = 4096

    private init() {
        logs.reserveCapacity(logCountLimitation + 1)
    }

    struct Log: Identifiable, Equatable {
        var id: UUID = .init()
        var message: String
    }

    @Published var logs: [Log] = []
    private var logsLock = NSLock()

    fileprivate func append(_ str: String) {
        DispatchQueue.global().async { [self] in
            logsLock.lock()
            var read = logs
            read.append(.init(message: str))
            if read.count > logCountLimitation {
                read.removeFirst(read.count - logCountLimitation)
            }
            DispatchQueue.withMainAndWait {
                self.logs = read
            }
            logsLock.unlock()
        }
    }
}

// overwrite print function
func print(_ str: String) {
    let str = str.trimmingCharacters(in: .newlines)
    Swift.print(str)
    Logger.shared.append(str)
}

struct DiagnosticLogView: View {
    @StateObject var logger = Logger.shared

    @State var highlight: Logger.Log.ID?
    @State var searchKey: String = ""

    var logs: [Logger.Log] {
        if searchKey.count > 0 {
            let key = searchKey.lowercased()
            return logger
                .logs
                .filter { $0.message.lowercased().contains(key) }
        } else {
            return logger.logs
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ScrollViewReader { reader in
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(logs) { log in
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(log.message)
                                .textSelection(.enabled)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundColor(.accentColor)
                                .opacity(highlight == log.id ? 0.1 : 0)
                                .animation(.interactiveSpring(), value: highlight)
                        )
                        .tag(log.id)
                        .onHover { hover in
                            if hover {
                                highlight = log.id
                            } else {
                                highlight = nil
                            }
                        }
                    }
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                }
                .padding(10)
                .onChange(of: logger.logs) { newValue in
                    guard let id = newValue.last?.id else {
                        return
                    }
                    withAnimation(.interactiveSpring()) {
                        reader.scrollTo(id)
                    }
                }
            }
        }
        .searchable(text: $searchKey)
        .toolbar {
            ToolbarItem {
                Button {
                    let panel = NSSavePanel()
                    panel.nameFieldStringValue = "ActionBee Diagnostic \(Int(Date().timeIntervalSince1970)).log"
                    guard let window = NSApp.keyWindow else {
                        return
                    }
                    panel.beginSheetModal(for: window) { resp in
                        guard resp == .OK, let url = panel.url else {
                            return
                        }
                        let logs = logger.logs.map(\.message).joined(separator: "\n")
                        try? logs.write(toFile: url.path, atomically: true, encoding: .utf8)
                    }
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Diagnostic")
        .usePreferredContentSize()
    }
}
