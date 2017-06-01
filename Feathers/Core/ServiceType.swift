//
//  ServiceType.swift
//  Feathers
//
//  Created by Brendan Conron on 5/21/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

/// Interface that all services must conform to.
public protocol ServiceType {

    /// The service's path, unmodifable once created.
    var path: String { get }

    /// If the service supports real time events or not.
    var supportsRealtimeEvents: Bool { get }

    /// Setup up the service with the necessary dependencies to execute requests.
    ///
    /// - Parameters:
    ///   - app: Main feathers app. Services maintain a weak reference.
    ///   - path: The service path.
    func setup(app: Feathers, path: String)

    /// Request data using one of the service methods.
    ///
    /// - Parameter method: Service method.
    /// - Returns: `SignalProducer` that emits a response or errors.
    func request(_ method: Service.Method) -> SignalProducer<Response, AnyFeathersError>

    /// Register before hooks with the service.
    ///
    /// - Parameter hooks: Before hooks to register.
    func before(_ hooks: Service.Hooks)

    /// Register after hooks with the service.
    ///
    /// - Parameter hooks: After hooks to register.
    func after(_ hooks: Service.Hooks)

    /// Register error hooks with the service.
    ///
    /// - Parameter hooks: Error hooks to register.
    func error(_ hooks: Service.Hooks)

    /// Fetch a service's hooks.
    ///
    /// - Parameter kind: The kind of hook.
    /// - Returns: Hooks registered for `kind`, if any exist.
    func hooks(for kind: HookObject.Kind) -> Service.Hooks?

    /// Register for a real-time event to listen for changing data.
    /// Signal will continue to emit until disposed.
    ///
    /// - Parameter event: Real-time event to listen for.
    /// - Returns: `Signal` that emits any data. Never errors.
    func on(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError>

    /// Register for a real-time event but only one time. Signal will emit once
    /// then dispose.
    ///
    /// - Parameter event: Real-time event to listen for.
    /// - Returns: Signal that emits a value once, if ever.
    func once(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError>

    /// Unregister for a real-time event.
    ///
    /// - Parameter event: Event to unregister for.
    func off(event: Service.RealTimeEvent)
    
}
