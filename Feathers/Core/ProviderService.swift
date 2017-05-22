//
//  ProviderService.swift
//  Feathers
//
//  Created by Brendan Conron on 5/21/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public class ProviderService: Service {

    private let provider: Provider

    public init(provider: Provider) {
        self.provider = provider
        super.init()
    }

    public override func request(_ method: Service.Method) -> SignalProducer<Response, FeathersError> {
        let endpoint = constructEndpoint(from: method)
        return provider.request(endpoint: endpoint)
    }


    /// Given a service method, construct an endpoint.
    ///
    /// - Parameter method: Service method.
    /// - Returns: `Endpoint` object.
    private func constructEndpoint(from method: Service.Method) -> Endpoint {
        guard let provider = app?.provider else { fatalError("provider must be given to the service before making requests") }
        var endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: nil, authenticationConfiguration: app?.authenticationConfiguration ?? AuthenticationConfiguration())
        if let storage = app?.authenticationStorage,
            let accessToken = storage.accessToken {
            endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: accessToken, authenticationConfiguration: app?.authenticationConfiguration ?? AuthenticationConfiguration())
        }
        return endpoint
    }

    /// Register to listen for a real-time event.
    ///
    /// - Parameters:
    ///   - event: Event to listen for.
    ///   - callback: Event callback.
    ///
    /// - Note: If the provider doesn't conform to `RealTimeProvider`, nothing will happen.
    override public func on(event: RealTimeEvent) -> Signal<[String: Any], NoError> {
        return app?.provider.on(event: "\(path) \(event.rawValue)") ?? .never
    }

    /// Register to listen for an event once and only once.
    ///
    /// - Parameters:
    ///   - event: Event to listen for.
    ///   - callback: Single-use-callback.
    override public func once(event: RealTimeEvent) -> Signal<[String: Any], NoError> {
        return app?.provider.once(event: "\(path) \(event.rawValue)") ?? .never
    }

    /// Unregister for an event. Must be called to end the stream.
    ///
    /// - Parameter event: Real-time event to unregister from.
    override public func off(event: RealTimeEvent) {
        app?.provider.off(event: event.rawValue)
    }

}
