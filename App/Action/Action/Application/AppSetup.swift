//
//  ApplicationSetup.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import AppKit

extension ActionApp {
    static let appBundleIdentifier: String = Bundle
        .main
        .bundleIdentifier ?? "wiki.qaq.unknown"

    static let appVersion: String =
        Bundle
            .main
            .infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "unknown"

    func applicationSetup() {
        assert(Thread.isMainThread)
        assert(getuid() != 0)

        print(
            """
            \(ActionApp.appBundleIdentifier) - \(ActionApp.appVersion)
            Location:
                [*] \(Bundle.main.bundleURL.path)
                [*] \(Self.documentDirectory.path)
            Environment: uid \(getuid()) gid \(getgid())
            """
        )

        disableDebuggerIfNeeded()

        _ = AXUIElementCreateSystemWide()
        _ = Executor.shared
        _ = PasteboardManager.shared
        _ = StatusBarManager.shared

        let timer = Timer(timeInterval: 0.5, repeats: true) { _ in
            appDelegate.switchDockIconMode()
        }
        RunLoop.current.add(timer, forMode: .common)

        #if DEBUG
            let debuggerTimer = Timer(timeInterval: 1, repeats: true) { _ in
                _ = 0
            }
            RunLoop.current.add(debuggerTimer, forMode: .common)
        #endif
    }

    private func disableDebuggerIfNeeded() {
        #if !DEBUG
            do {
                typealias ptrace = @convention(c) (_ request: Int, _ pid: Int, _ addr: Int, _ data: Int) -> AnyObject
                let open = dlopen("/usr/lib/system/libsystem_kernel.dylib", RTLD_NOW)
                if unsafeBitCast(open, to: Int.self) > 0x1024 {
                    let result = dlsym(open, "ptrace")
                    if let result = result {
                        let target = unsafeBitCast(result, to: ptrace.self)
                        _ = target(0x1F, 0, 0, 0)
                    }
                }
            }
        #endif
    }
}
