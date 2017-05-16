//
//  Feathers.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

/// Main application object. Creates services and provides an interface for authentication.
public final class Feathers {

    public typealias AuthenticationCallback = (String?, FeathersError?) -> ()

    /// Transport provider.
    public let provider: Provider

    /// Authentication store.
    private(set) public var authenticationStorage: AuthenticationStorage = EncryptedAuthenticationStore()

    /// Authentication configuration.
    private(set) public var authenticationConfiguration = AuthenticationConfiguration()

    private var services: [String: Service] = [:]

    /// Feather's initializer.
    ///
    /// - Parameter provider: Transport provider.
    public init(provider: Provider) {
        self.provider = provider
        provider.setup(app: self)
    }

    /// Create a service for the given path.
    ///
    /// - Parameter path: Service path.
    /// - Returns: Service object.
    public func service(path: String) -> Service {
        if let service = services[path] {
            return service
        }
        let service = Service()
        service.app = self
        service.provider = provider
        service.storage = authenticationStorage
        service.authenticationConfig = authenticationConfiguration
        return service
    }

    public func use(path: String, service: Service) {
        service.app = self
        service.provider = provider
        service.storage = authenticationStorage
        service.authenticationConfig = authenticationConfiguration
        services[path] = service
    }

    /// Configure any authentication options.
    ///
    /// - Parameter configuration: Authentication configuration object.
    public func configure(auth configuration: AuthenticationConfiguration) {
        authenticationConfiguration = configuration
        authenticationStorage = EncryptedAuthenticationStore(storageKey: configuration.storageKey)
    }

    /// Authenticate the application.
    ///
    /// - Parameters:
    ///   - credentials: Credentials to authenticate with.
    ///   - completion: Completion block.
    public func authenticate(_ credentials: [String: Any], completion: @escaping AuthenticationCallback) {
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

    /// Log out the application.
    ///
    /// - Parameter completion: Completion block.
    public func logout(_ completion: @escaping FeathersCallback) {
        provider.logout(path: authenticationConfiguration.path) { [weak self] error, response in
            if let error = error {
                completion(error, nil)
            } else if let response = response {
                self?.authenticationStorage.accessToken = nil
                completion(nil, response)
            } else {
                completion(.unknown, nil)
            }
        }
    }

}
