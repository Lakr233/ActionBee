//
//  AES.swift
//  PTFoundation
//
//  Created by Lakr Aream on 12/15/20.
//

import CommonCrypto
import Foundation
import KeychainAccess

private var bundleId: String {
    guard let id = Bundle.main.bundleIdentifier,
          !id.isEmpty
    else {
        fatalError("AES Engine requires bundle identifier to work")
    }
    return id
}

private let keychainServiceID = "wiki.qaq.ActionBee.kcAccess"
private let keychainMainKeyID = "wiki.qaq.ActionBee.keychainMainKeyID"
private let keychainLabel = "ActionBee Main Crypto Key"
private let keychainComment = "ActionBee requires this crypto key to access your encrypted data and sign sensitive information."

public struct AES {
    private let key: Data
    private let iv: Data

    public static let shared: AES = {
        #if DEBUG

            var keyBuilder = ""
            #if os(macOS)
                let platformExpert = IOServiceGetMatchingService(
                    kIOMainPortDefault,
                    IOServiceMatching("IOPlatformExpertDevice")
                )
                guard platformExpert > 0 else {
                    fatalError()
                }
                guard let serialNumber = (
                    IORegistryEntryCreateCFProperty(
                        platformExpert,
                        kIOPlatformSerialNumberKey as CFString,
                        kCFAllocatorDefault,
                        0
                    )
                    .takeUnretainedValue() as? String
                )
                else {
                    fatalError()
                }
                IOObjectRelease(platformExpert)
                keyBuilder = serialNumber
            #else
                keyBuilder = "0xdeadbeef & 0xbadf00d & 0xdeadbeef & 0xbadf00d & 0xdeadbeef & 0xbadf00d"
            #endif

            let key = keyBuilder + keyBuilder + keyBuilder
            guard let aes = AES(key: key, iv: key) else {
                fatalError("failed to initialize crypto engine")
            }
            return aes
        #else
            let keychain = Keychain(service: keychainServiceID)
            var retry = 3
            var key: String?
            repeat {
                defer { retry -= 1 }
                do {
                    let main = try keychain.getString(keychainMainKeyID)
                    if let main = main, main.count > 2 {
                        key = main
                        break
                    } else {
                        try keychain.remove(keychainMainKeyID)
                        let new = UUID().uuidString
                        key = new
                        try keychain
                            .label(keychainLabel)
                            .comment(keychainComment)
                            .set(new, key: keychainMainKeyID)
                        break
                    }
                } catch {
                    continue
                }
            } while retry > 0
            guard let key = key else {
                fatalError("failed to load crypto keys")
            }
            guard let aes = AES(key: key, iv: key) else {
                fatalError("failed to initialize crypto engine")
            }
            return aes
        #endif
    }()

    internal init?(key initKey: String, iv initIV: String) {
        if initKey.count < kCCKeySizeAES128 || initIV.count < kCCBlockSizeAES128 {
            return nil
        }
        var initKey = initKey
        while initKey.count < 32 {
            initKey += initKey
        }
        while initKey.count > 32 {
            initKey.removeLast()
        }
        guard initKey.count == kCCKeySizeAES128 || initKey.count == kCCKeySizeAES256,
              let keyData = initKey.data(using: .utf8)
        else {
            return nil
        }

        var initIV = initIV
        while initIV.count < kCCBlockSizeAES128 {
            initIV += initIV
        }
        while initIV.count > kCCBlockSizeAES128 {
            initIV.removeLast()
        }
        guard initIV.count == kCCBlockSizeAES128, let ivData = initIV.data(using: .utf8) else {
            return nil
        }

        key = keyData
        iv = ivData
    }

    // MARK: - API

    public func encrypt(data: Data) -> Data? {
        crypt(data: data, option: CCOperation(kCCEncrypt))
    }

    public func decrypt(data: Data) -> Data? {
        crypt(data: data, option: CCOperation(kCCDecrypt))
    }

    // MARK: - INTERNAL

    private func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else { return nil }

        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)

        let keyLength = key.count
        let options = CCOptions(kCCOptionPKCS7Padding)

        var bytesLength = Int(0)

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }

        guard UInt32(status) == UInt32(kCCSuccess) else {
            assertionFailure()
            return nil
        }

        cryptData.removeSubrange(bytesLength ..< cryptData.count)
        return cryptData
    }
}
