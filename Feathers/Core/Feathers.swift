//
//  Feathers.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
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
    /// This method uses some fancy indirection and wraps every service in a `ServiceWrapper` instance
    /// that's responsible for running the hook chain and proxying methods to the wrapped service.
    ///
    /// - Parameter path: Service path.
    /// - Returns: Service object.
    public func service(path: String) -> ServiceType {
        let servicePath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let service = services[servicePath] else {
            // If no service has been registered or requested for at this path, 
            // create one around the transport provider.
            let providerService = ProviderService(provider: provider)
            providerService.setup(app: self, path: servicePath)
            // Store it so the service is retained and hooks can be registered.
            services[servicePath] = providerService
            // Create the wrapper
            let wrapper = ServiceWrapper(service: providerService)
            wrapper.setup(app: self, path: servicePath)
            return wrapper
        }
        let wrapper = ServiceWrapper(service: service)
        wrapper.setup(app: self, path: servicePath)
        return wrapper
    }

    public func use(path: String, service: ServiceType) {
        let servicePath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        service.setup(app: self, path: servicePath)
        services[servicePath] = service
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
    public func authenticate(_ credentials: [String: Any]) -> SignalProducer<[String: Any], AnyFeathersError> {
        return provider.authenticate(authenticationConfiguration.path, credentials: credentials)
            .flatMap(.latest) { response -> SignalProducer<[String: Any], AnyFeathersError> in
                if case let .object(object) = response.data,
                    let json = object as? [String: Any] {
                    return SignalProducer(value: json)
                }
                return SignalProducer(error: AnyFeathersError(FeathersNetworkError.unknown))
            }.on(failed: { [weak self] _ in
                self?.authenticationStorage.accessToken = nil
            }, value: { [weak self] value in
                guard let token = value["accessToken"] as? String else { return }
                self?.authenticationStorage.accessToken = token
            })
    }
    
    /// Log out the application.
    ///
    /// - Returns: Promise that emits a response.
    public func logout() -> SignalProducer<Response, AnyFeathersError> {
        return provider.logout(path: authenticationConfiguration.path)
            .on(value: { [weak self] _ in
                self?.authenticationStorage.accessToken = nil
        })
    }

}
