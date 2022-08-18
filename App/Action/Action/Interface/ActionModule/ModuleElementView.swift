//
//  ModuleElementView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/15.
//

import SwiftUI

struct ModuleElementView: View {
    let id: UUID
    let notificationPublisher = NotificationCenter
        .default
        .publisher(for: .editAction)
        .receive(on: RunLoop.main)

    @StateObject var actionManager = ActionManager.shared
    @State var openEdit: Bool = false

    var gradientColor: Gradient {
        if actionManager.enabledActions.contains(id) {
            if actionManager.binaries[id] == nil {
                return Gradient(colors: [.pink, .red])

            } else {
                return Gradient(colors: [.yellow, .orange])
            }
        } else {
            return Gradient(colors: [.gray, .black.opacity(0.8)])
        }
    }

    var body: some View {
        Button {
            openEdit = true
        } label: {
            LinearGradient(
                gradient: gradientColor,
                startPoint: .topTrailing,
                endPoint: .bottomTrailing
            )
            .overlay { Color.orange.opacity(0.5) }
            .overlay { content }
            .cornerRadius(8)
            .clipped()
            .frame(width: 140, height: 80)
        }
        .overlay {
            if actionManager.binaries[id] == nil {
                Image(systemName: "xmark.octagon.fill")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(4)
            }
        }
        .buttonStyle(.plain)
        .onHover { hover in
            if hover {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .onReceive(notificationPublisher) { notification in
            guard let notificationId = notification.object as? UUID,
                  notificationId == id
            else {
                return
            }
            openEdit = true
        }
        .sheet(isPresented: $openEdit) {
            ModuleEditView(id: id)
        }
    }

    var content: some View {
        Group {
            if let action = actionManager[id] {
                VStack(spacing: 4) {
                    Image(systemName: action.icon)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text(action.name)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(
                    Image(systemName: action.icon)
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.1)
                        .offset(x: 50, y: 10)
                )
                .padding(8)
            } else {
                Text("Error").font(.headline)
            }
        }
    }
}
