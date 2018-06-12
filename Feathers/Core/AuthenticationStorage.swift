//
//  AuthenticationStorage.swift
//  Feathers
//
//  Created by Brendan Conron on 5/3/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import KeychainAccess

/// Authentication storage protocol.
public protocol AuthenticationStorage: class {

    init(storageKey: String)
    var accessToken: String? { get set }

}

/// An encrypted authentication store. Uses the keychain to store a token.
public final class EncryptedAuthenticationStore: AuthenticationStorage {

    private let keychain = Keychain(service: "com.feathers")
    private let storageKey: String

    /// Access token. Cleared by setting to `nil`.
    public var accessToken: String? {
        get {
            return keychain[storageKey]
        } set {
            if let value = newValue {
                keychain[storageKey] = value
            } else {
                // clear the keychain
                keychain[storageKey] = nil
            }
        }
    }

    public init(storageKey: String = "feathers-jwt") {
        self.storageKey = storageKey
    }

}
