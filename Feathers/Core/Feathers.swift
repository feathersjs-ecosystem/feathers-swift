//
//  Feathers.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift

/// Main application object. Creates services and provides an interface for authentication.
public final class Feathers {

    /// Transport provider.
    public let provider: Provider

    /// Authentication store.
    private(set) public var authenticationStorage: AuthenticationStorage = EncryptedAuthenticationStore()

    /// Authentication configuration.
    private(set) public var authenticationConfiguration = AuthenticationConfiguration()

    private var services: [String: ServiceType] = [:]

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
    public func service(path: String) -> ServiceType {
        let servicePath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let service = services[servicePath] else {
            let providerService = ProviderService(provider: provider)
            providerService.setup(app: self, path: servicePath)
            return ServiceWrapper(service: providerService)
        }
        return ServiceWrapper(service: service)
    }

    public func use(path: String, service: ServiceType) {
        let servicePath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        services[servicePath] = service
    }

    public func use(paths: [String], service: ServiceType) {
        paths.forEach { [weak self] path in
            let servicePath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            self?.services[servicePath] = service
        }
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
    public func authenticate(_ credentials: [String: Any]) -> SignalProducer<String, FeathersError> {
        return provider.authenticate(authenticationConfiguration.path, credentials: credentials)
            .flatMap(.latest) { response -> SignalProducer<String, FeathersError> in
                if case let .jsonObject(object) = response.data,
                let json = object as? [String: Any],
                let accessToken = json["accessToken"] as? String {
                    return SignalProducer(value: accessToken)
                }
                return SignalProducer(error: .unknown)
            }.on(failed: { [weak self] _ in
                self?.authenticationStorage.accessToken = nil
            }, value: { [weak self] value in
                self?.authenticationStorage.accessToken = value
            })
    }
    
    /// Log out the application.
    ///
    /// - Returns: Promise that emits a response.
    public func logout() -> SignalProducer<Response, FeathersError> {
        return provider.logout(path: authenticationConfiguration.path)
            .on(value: { [weak self] _ in
                self?.authenticationStorage.accessToken = nil
        })
    }

}
