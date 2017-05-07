//
//  AuthenticationStorage.swift
//  Feathers
//
//  Created by Brendan Conron on 5/3/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import KeychainSwift

public protocol AuthenticationStorage {

    init(storageKey: String)
    var accessToken: String? { get set }

}

public struct EncryptedAuthenticationStore: AuthenticationStorage {

    private let keychain = KeychainSwift()
    private let storageKey: String

    public var accessToken: String? {
        get { return keychain.get(storageKey) }
        set {
            guard let value = newValue else { return }
            keychain.set(value, forKey: storageKey)
        }
    }

    public init(storageKey: String) {
        self.storageKey = storageKey
    }

}
