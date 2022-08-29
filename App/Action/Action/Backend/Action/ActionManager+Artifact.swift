//
//  ActionManager+Artifact.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import Foundation

private let artifactPathExtension = ".ActionBeeArtifact"

extension ActionManager {
    struct ModuleArtifact: Codable {
        let id: Action.ID
        let signature: String

        init?(id: Action.ID, copyingArtifactAt atUrl: URL) {
            self.id = id
            let targetDir = Self.obtainArtifactUrlForAction(withId: id)
            do {
                try? FileManager.default.removeItem(at: targetDir)
                var isDir = ObjCBool(false)
                guard FileManager.default.fileExists(atPath: atUrl.path, isDirectory: &isDir) else {
                    return nil
                }
                if isDir.boolValue {
                    try FileManager.default.copyItem(at: atUrl, to: targetDir)
                } else {
                    try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)
                    let name = atUrl.lastPathComponent
                    let target = targetDir.appendingPathComponent(name)
                    try FileManager.default.copyItem(at: atUrl, to: target)
                }
                signature = try Self.generatePackageSignature(at: targetDir)
            } catch {
                print("[E] \(error.localizedDescription)")
                return nil
            }
        }

        static func deletingDotFiles(at atUrl: URL) throws {
            let enumerator = FileManager.default.enumerator(atPath: atUrl.path)
            while let subPath = enumerator?.nextObject() as? String {
                let url = atUrl.appendingPathComponent(subPath)
                var shouldClean = false
                if subPath == ".DS_Store" { shouldClean = true }
                if subPath.hasPrefix("._") { shouldClean = true }
                if shouldClean {
                    print("[*] deleting dot files inside artifact \(url.path)")
                    try FileManager.default.removeItem(at: url)
                }
            }
        }

        static func generatePackageSignature(at atUrl: URL) throws -> String {
            try deletingDotFiles(at: atUrl)
            var signatureDic = [String: String]()
            let enumerator = FileManager.default.enumerator(atPath: atUrl.path)
            while let subPath = enumerator?.nextObject() as? String {
                let path = atUrl.appendingPathComponent(subPath)
                var isDir = ObjCBool(false)
                guard FileManager
                    .default
                    .fileExists(atPath: path.path, isDirectory: &isDir)
                else {
                    throw GenericActionError.brokenResources
                }
                let data = try Data(contentsOf: path)
                let hash = data.sha256()
                signatureDic[subPath] = hash
            }
            var hasher = String()
            let valueArray = signatureDic.sorted { $0.key < $1.key }
            for (key, value) in valueArray {
                hasher += key
                hasher += value
                hasher += "\n"
            }
            guard let signature = hasher.data(using: .utf8)?.sha256() else {
                throw GenericActionError.unknown
            }
            return signature
        }

        static func obtainArtifactUrlForAction(withId: Action.ID) -> URL {
            ActionManager.shared
                .actionArtifactBaseUrl
                .appendingPathComponent(withId.uuidString)
                .appendingPathExtension(artifactPathExtension)
        }

        func obtainArtifactUrl() -> URL {
            Self.obtainArtifactUrlForAction(withId: id)
        }

        func validateSignature() -> Bool {
            do {
                let testSignature = try Self.generatePackageSignature(at: obtainArtifactUrl())
                return signature == testSignature
            } catch {
                print("[E] \(error.localizedDescription)")
                return false
            }
        }
    }
}
