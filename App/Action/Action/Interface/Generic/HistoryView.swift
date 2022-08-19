//
//  HistoryView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var actionManager = ActionManager.shared

    @State var searchKey = ""
    @State var hoverId: ActionManager.HistoryElement.ID? = nil

    var histories: [ActionManager.HistoryElement] {
        if searchKey.isEmpty {
            return actionManager.histories
        }
        let key = searchKey.lowercased()
        return actionManager
            .histories
            .filter { $0.search(with: key) }
    }

    var body: some View {
        Group {
            if histories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.dashed.badge.record")
                        .font(.system(size: 26, weight: .regular, design: .rounded))
                    Text("No History Was Found")
                        .font(.system(.footnote))
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(histories.reversed()) { record in
                            HStack(alignment: .top, spacing: 6) {
                                Text("> ")
                                    .font(.system(.subheadline, design: .rounded))
                                Divider()
                                HistoryRecordView(record: record)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(2)
                            .background(Color.accentColor.opacity(record.id == hoverId ? 0.1 : 0))
                            .cornerRadius(8)
                            .onHover { hover in
                                hoverId = hover ? record.id : nil
                            }
                        }
                    }
                    .padding(10)
                }
                .animation(.interactiveSpring(), value: hoverId)
                .animation(.interactiveSpring(), value: searchKey)
            }
        }

        .toolbar {
            ToolbarItem {
                Button { clearHistory() } label: {
                    Label("Clear History", systemImage: "xmark.circle")
                }
            }
        }
        .searchable(text: $searchKey)
        .navigationTitle("History")
        .usePreferredContentSize()
    }

    func clearHistory() {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = NSLocalizedString("Are you sure you want to delete all history records? This operation can not be undone.", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Delete", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        guard let window = NSApp.keyWindow else {
            return
        }
        alert.beginSheetModal(for: window) { resp in
            guard resp == .alertFirstButtonReturn else {
                return
            }
            actionManager.histories = []
        }
    }
}

struct HistoryRecordView: View {
    let record: ActionManager.HistoryElement
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pasteboard Event")
                .font(.system(.subheadline, design: .monospaced))
                .bold()
            Text("Length: \(record.event.content.count) Action Candidates: \(record.actionCandidates.count)")
            if !record.succeedAction.isEmpty {
                Divider()
                ForEach(record.succeedAction) { item in
                    Text("+ [\(ActionManager.shared[item.action]?.name ?? "Deleted Action")]")
                    Text("  Post Action: \(item.recipeAction)")
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text("  Content: \(item.recipeContent)").lineLimit(1)
                    }
                }
                .foregroundColor(.blue)
            }
            if !record.failedAction.isEmpty {
                Divider()
                ForEach(record.failedAction) { item in
                    Text("- [\(ActionManager.shared[item.action]?.name ?? "Deleted Action")]")
                    Text("  \(item.errorHint)")
                }
                .foregroundColor(.pink)
            }
            Divider()
            Text(record.date.formatted(date: .complete, time: .complete))
                .opacity(0.5)
        }
        .font(.system(.footnote, design: .monospaced))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
