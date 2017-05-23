//
//  ServiceWrapper.swift
//  Feathers
//
//  Created by Brendan Conron on 5/21/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.NoError

/// Wraps a given service and executes all hooks and the service request.
/// This class exists so that users can write their own services and
/// not have to worry about running before, after, and error hooks themselves.
/// By wrapping the given service, the service wrapper can manage all
/// request execution. Also serves as a proxy to the underlying service.
final public class ServiceWrapper: ServiceType {

    /// Weak reference to main feathers app.
    final private weak var app: Feathers?

    /// Internally wrapped service.
    final private let service: ServiceType

    // MARK: - Initialization

    internal init(service: ServiceType) {
        self.service = service
    }

    // MARK: - ServiceType

    final public func setup(app: Feathers, path: String) {
        self.app = app
    }

    final public var path: String {
        return service.path
    }

    final public var supportsRealtimeEvents: Bool {
        return service.supportsRealtimeEvents
    }


    /// Execute a request against the wrapped service and runs all hooks registered.
    ///
    ///  The execution flow of this method is as follows:
    ///
    ///  before hooks -> service request -> after hooks
    ///
    ///  If at any point an error is emitted or `hookObject.error` is set manually, the chain 
    ///  immediately stops and runs the registered error hooks.
    ///
    ///  If `hookObject.result` is set, the service request will be skipped and after hooks will run.
    /// - Parameter method: Service method to execute.
    /// - Returns: `SignalProducer` that emits a response.
    final public func request(_ method: Service.Method) -> SignalProducer<Response, FeathersError> {
        guard let application = app else {
            print("feathers: no application exists on the service. `setup` was not called.")
            return .interrupted
        }
        // Closure that maps all registered hooks into a single producer.
        let reduceHooksClosure: (SignalProducer<HookObject, FeathersError>, Hook) -> SignalProducer<HookObject, FeathersError> = { acc, current in
            return acc.flatMap(.concat) { value in
                return current.run(with: value)
            }
        }
        let beforeHookObject = HookObject(type: .before, app: application, service: service, method: method)
        // Get all the hooks
        let beforeHooks = service.retrieveHooks(for: .before)?.hooks(for: method) ?? []
        let afterHooks = service.retrieveHooks(for: .after)?.hooks(for: method) ?? []
        let errorHooks = service.retrieveHooks(for: .error)?.hooks(for: method) ?? []
        // Build up the before chains
        let beforeChain = beforeHooks.reduce(SignalProducer(value: beforeHookObject), reduceHooksClosure)

        let chain = beforeChain.flatMap(.concat) { [weak self] hook -> SignalProducer<Response, FeathersError> in
            guard let vSelf = self else {
                return .interrupted
            }
            // If the result is set, skip the service request.
            if let _ = hook.result {
                let afterHookObject = hook.object(with: .after)
                let afterChain = afterHooks.reduce(SignalProducer(value: afterHookObject), reduceHooksClosure)
                return afterChain.flatMap(.concat) {
                    return $0.result != nil ? SignalProducer(value: $0.result!) : SignalProducer(error: .unknown)
                }
                // If the error is set, error out.
            } else if let error = hook.error {
                return SignalProducer(error: error)
            } else {
                // Otherwise, execute the service request.
                return vSelf.service.request(method)
                    // When the service request has completed and emitted a response,
                    // run all the after hooks.
                    .flatMap(.latest) { response -> SignalProducer<Response, FeathersError> in
                        let afterHookObject = hook.object(with: .after).objectByAdding(result: response)
                        let afterChain = afterHooks.reduce(SignalProducer(value: afterHookObject), reduceHooksClosure)
                        return afterChain.flatMap(.concat) { value in
                            return value.result != nil ? SignalProducer(value: value.result!) : SignalProducer(error: .unknown)
                        }
                }
            }
        }
        // If at any point along the chain an error is emitted, recover by running all the error hooks.
        return chain.flatMapError { [weak self] error -> SignalProducer<Response, FeathersError> in
            guard let vSelf = self else { return SignalProducer(error: .unknown) }
            let errorHookObject = HookObject(type: .error, app: application, service: vSelf, method: method).objectByAdding(error: error)
            let errorChain = errorHooks.reduce(SignalProducer(value: errorHookObject), reduceHooksClosure)
            return errorChain.flatMap(.concat) { hookObject -> SignalProducer<Response, FeathersError> in
                // If the hook error exists, send that to the user, otherwise emit the original error that caused error hooks to run.
                return hookObject.error != nil ? SignalProducer(error: hookObject.error!) : SignalProducer(error: error)
            }
        }
    }

    final public func hooks(before: Service.Hooks? = nil, after: Service.Hooks? = nil, error: Service.Hooks? = nil) {
        service.hooks(before: before, after: after, error: error)
    }

    final public func retrieveHooks(for kind: HookObject.Kind) -> Service.Hooks? {
        return service.retrieveHooks(for: kind)
    }

    final public func on(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError> {
        return service.on(event: event)
    }

    final public func once(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError> {
        return service.once(event: event)
    }

    final public func off(event: Service.RealTimeEvent) {
        service.off(event: event)
    }

}
