//
//  Executor.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/26.
//

import AuxiliaryExecute
import Foundation

final class Executor {
    static let shared = Executor()

    let executorDir = ActionApp
        .documentDirectory
        .appendingPathComponent("Executor")

    private init() {
        let whoami = "/usr/bin/whoami"
        let receipt = AuxiliaryExecute.spawn(command: whoami)
        let username = receipt.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        guard receipt.exitCode == 0, !username.isEmpty /* , username != "root" */ else {
            fatalError("Malformed application permission")
        }
        print("[*] whoami \(username)")

        do {
            let findEnv = AuxiliaryExecute.spawn(
                command: "/bin/zsh",
                args: ["-c", "source ~/.zshrc 1>/dev/null 2>/dev/null && echo $PATH"]
            )
            let env = findEnv.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            print("[*] setting up env PATH value \(findEnv.stdout)")
            let envPathBuilder = env.components(separatedBy: ":")
                .filter { FileManager.default.fileExists(atPath: $0) }
            let origPathBuilder = (
                ProcessInfo
                    .processInfo
                    .environment["PATH"] ?? ""
            )
            .components(separatedBy: ":")
            .filter { FileManager.default.fileExists(atPath: $0) }
            let newPath = Array(Set(envPathBuilder + origPathBuilder))
                .joined(separator: ":")

            setenv("PATH", newPath, 1)
        }

        try? FileManager.default.createDirectory(at: executorDir, withIntermediateDirectories: true)
    }

    enum ExecutorError: Error {
        case unknown
    }

    func obtainXcodeCommandLineToolLocation() -> URL? {
        let receipt = AuxiliaryExecute.spawn(
            command: "/usr/bin/xcode-select",
            args: ["--print-path"]
        )
        let path = receipt
            .stdout
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard path != "/",
              path.hasPrefix("/"),
              FileManager.default.fileExists(atPath: path)
        else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    func unarchiveTar(at: URL, toDest: URL) throws {
        let receipt = AuxiliaryExecute.spawn(
            command: "/usr/bin/tar",
            args: ["-xf", at.path, "--directory", toDest.path]
        )
        guard receipt.exitCode == 0 else {
            throw ExecutorError.unknown
        }
    }

    func speak(_ str: String) {
        AuxiliaryExecute.spawn(
            command: "/usr/bin/say",
            args: [str]
        )
    }
}
