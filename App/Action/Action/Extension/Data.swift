//
//  Data.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import CommonCrypto
import Foundation

extension Data {
    func sha256() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        let sha256Hex = hexBytes.joined()
        return sha256Hex
    }
}
