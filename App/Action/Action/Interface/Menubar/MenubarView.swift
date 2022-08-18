//
//  MenubarView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import Colorful
import SwiftUI

struct MenubarView: View {
    @StateObject var menubar = Menubar.shared
    @StateObject var actionManager = ActionManager.shared

    var lastHistory: ActionManager.HistoryElement? {
        if let last = actionManager.histories.last,
           last.date > ActionApp.bootTime
        {
            return last
        }
        return nil
    }

    var body: some View {
        ZStack {
            if actionManager.actionRunning {
                ZStack {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text(actionManager.actionRunningHint)
                            .font(.system(.subheadline, design: .monospaced))
                    }
                }
                .frame(width: 400, height: 200)
            } else if let lastHistory = lastHistory {
                VStack {
                    Spacer().frame(height: 16)
                    Image(
                        systemName: lastHistory.failedAction.isEmpty
                            ? "checkmark.circle.fill"
                            : "checkmark.circle.trianglebadge.exclamationmark"
                    )
                    .foregroundColor(lastHistory.failedAction.isEmpty ? .green : .orange)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    Spacer().frame(height: 16)
                    HistoryRecordView(record: lastHistory)
                    Divider().hidden()
                }
                .padding()
                .frame(width: 400)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image("Avatar")
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("ActionBee is ready to accept pasteboard events.")
                            .font(.headline)
                    }

                    RandomCodeTextView()
                    Divider().hidden()
                }
                .padding()
                .frame(width: 400, height: 200)
            }
        }
    }
}
