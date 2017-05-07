//
//  Feathers.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

public final class Feathers {

    public let provider: Provider
    private(set) public var authenticationStorage: AuthenticationStorage = EncryptedAuthenticationStore()

    private var authOptions = AuthenticationOptions()

    public init(provider: Provider) {
        self.provider = provider
    }

    public func service(path: String) -> Service {
        return Service(provider: provider, path: path)
    }

    public func configure(auth options: AuthenticationOptions) {
        authOptions = options
        authenticationStorage = EncryptedAuthenticationStore(storageKey: options.storageKey)
    }

    public func authenticate(_ credentials: [String: Any], completion: @escaping (Bool, FeathersError?) -> ()) {
        provider.authenticate(authOptions.path, credentials: credentials) { error, response in
            completion(true, nil)
        }
    }

}
