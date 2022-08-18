//
//  UserDefault.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/15.
//

import Foundation

#if DEBUG
    private let keyPrefix = "debug."
#else
    private let keyPrefix = ""
#endif

@propertyWrapper
struct UserDefaultsWrapper<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    init(key: String, defaultValue: Value, storage: UserDefaults = .standard) {
        self.key = keyPrefix + key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

extension UserDefaultsWrapper where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, storage: storage)
    }
}

private let documentEncoder = PropertyListEncoder()
private let documentDecoder = PropertyListDecoder()

@propertyWrapper
struct CodableDefaultsWrapper<Value: Codable> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    init(key: String, defaultValue: Value, storage: UserDefaults = .standard) {
        self.key = keyPrefix + key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: Value {
        get {
            guard let data = storage.value(forKey: key) as? Data,
                  let value = try? documentDecoder.decode(Value.self, from: data)
            else {
                return defaultValue
            }
            return value
        }
        set {
            guard let data = try? documentEncoder.encode(newValue) else {
                return
            }
            storage.setValue(data, forKey: key)
        }
    }
}

@propertyWrapper
struct EncryptedCodableDefaultsWrapper<Value: Codable> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    init(key: String, defaultValue: Value, storage: UserDefaults = .standard) {
        self.key = keyPrefix + key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: Value {
        get {
            guard let data = storage.value(forKey: key) as? Data,
                  let decrypted = AES.shared.decrypt(data: data),
                  let value = try? documentDecoder.decode(Value.self, from: decrypted)
            else {
                return defaultValue
            }
            return value
        }
        set {
            guard let data = try? documentEncoder.encode(newValue),
                  let encrypt = AES.shared.encrypt(data: data)
            else {
                return
            }
            storage.setValue(encrypt, forKey: key)
        }
    }
}

extension EncryptedCodableDefaultsWrapper where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, storage: storage)
    }
}
