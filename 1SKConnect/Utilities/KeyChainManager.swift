//
//  KeyChainManager.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import KeychainAccess

class KeyChainManager {

    static let shared = KeyChainManager()
    private let keychain = Keychain(service: "1SK")

    private init() {

    }

    var accessToken: String? {
        get {
            return keychain[SKKey.accessToken]
        }

        set {
            keychain[SKKey.accessToken] = newValue
        }
    }

    var encryptionKey: Data {
        get {
            if let key = try? keychain.getData(SKKey.encrytionKey) {
                return key
            } else {
                // Genarate random encryption key
                let keyData = NSMutableData(length: 64)!
                 _ = SecRandomCopyBytes(kSecRandomDefault, 64, keyData    .mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
                try? keychain.set(keyData as Data, key: SKKey.encrytionKey)
                return keyData as Data
            }
        }

        set {
            try? keychain.set(newValue, key: SKKey.encrytionKey)
        }
    }

    func removeKey(_ key: String) {
        try? keychain.remove(key)
    }
}
