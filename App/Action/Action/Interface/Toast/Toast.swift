//
//  Toast.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/17.
//

import Cocoa
import Foundation
import SwiftUI

private class ToastWindow: NSWindow {
    init(with screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        alphaValue = 1

        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        backgroundColor = .clear

        ignoresMouseEvents = true
        isMovable = false
        isMovableByWindowBackground = false

        // .fullScreenAuxiliary .stationary .canJoinAllSpaces
        collectionBehavior = NSWindow.CollectionBehavior(rawValue: 273)
        styleMask = .borderless

        // The standard ScreenSaverView class actually sets the window
        // level to 2002, not the 1000 defined by NSScreenSaverWindowLevel
        // and kCGScreenSaverWindowLevel
        /// https://github.com/genekogan/ofxScreenGrab/blob/master/src/macGlutfix.m
        level = NSWindow.Level(rawValue: 2005)

        setFrameOrigin(screen.frame.origin)

        makeKeyAndOrderFront(nil)
        hasShadow = false
    }
}

private class ToastWindowController: NSWindowController {
    init(with screen: NSScreen, systemIcon: String, message: String) {
        super.init(window: ToastWindow(with: screen))
        contentViewController = NSHostingController(
            rootView: ToastView(systemIcon: systemIcon, message: message)
        )
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }
}

struct ToastView: View {
    let systemIcon: String
    let message: String

    @State var opacity: Double = 1

    var body: some View {
        GeometryReader { _ in
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    content
                    Spacer()
                }
                Spacer()
            }
        }
        .opacity(opacity)
        .animation(.interactiveSpring(), value: opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                opacity = 0
            }
        }
    }

    var content: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: systemIcon)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text(message)
                .font(.system(.headline, design: .rounded))
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

enum Toast {
    static func post(systemIcon: String, message: String) {
        guard let screen = NSScreen.main else {
            return
        }
        let windowController = ToastWindowController(
            with: screen,
            systemIcon: systemIcon,
            message: message
        )
        windowController.window?.setFrameOrigin(screen.frame.origin)
        windowController.window?.setContentSize(screen.frame.size)
        windowController.window?.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            windowController.window?.close()
        }
    }
}
