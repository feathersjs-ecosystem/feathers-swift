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

    private(set) public var authenticationConfiguration = AuthenticationConfiguration()

    public init(provider: Provider) {
        self.provider = provider
    }

    public func service(path: String) -> Service {
        return Service(provider: provider, path: path, storage: authenticationStorage, authenticationConfig: authenticationConfiguration)
    }

    public func configure(auth configuration: AuthenticationConfiguration) {
        authenticationConfiguration = configuration
        authenticationStorage = EncryptedAuthenticationStore(storageKey: configuration.storageKey)
    }

    public func authenticate(_ credentials: [String: Any], completion: @escaping (String?, FeathersError?) -> ()) {
        provider.authenticate(authenticationConfiguration.path, credentials: credentials) { [weak self] error, response in
            if let error = error {
                completion(nil, error)
            } else if let response = response,
                case let .jsonObject(object) = response.data,
                let json = object as? [String: Any],
                let accessToken = json["accessToken"] as? String {
                    self?.authenticationStorage.accessToken = accessToken
                    completion(accessToken, nil)
            } else {
                completion(nil, .unknown)
            }
        }
    }

}
