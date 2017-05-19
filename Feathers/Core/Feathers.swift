//
//  Feathers.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit

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
        let servicePath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if let service = services[servicePath] {
            return service
        }
        let service = Service(path: servicePath)
        service.setup(app: self)
        services[servicePath] = service
        return service
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
    /// - Returns: Promise that emits an access token.
    public func authenticate(_ credentials: [String: Any]) -> Promise<String> {
        return provider.authenticate(authenticationConfiguration.path, credentials: credentials)
            .then { [weak self] response in
                if case let .jsonObject(object) = response.data,
                let json = object as? [String: Any],
                let accessToken = json["accessToken"] as? String {
                    self?.authenticationStorage.accessToken = accessToken
                    return Promise(value: accessToken)
                }
                return Promise(error: FeathersError.unknown)
        }
    }
    
    /// Log out the application.
    ///
    /// - Returns: Promise that emits a response.
    public func logout() -> Promise<Response> {
        return provider.logout(path: authenticationConfiguration.path)
            .then { [weak self] response in
                self?.authenticationStorage.accessToken = nil
                return Promise(value: response)
        }
    }

}
