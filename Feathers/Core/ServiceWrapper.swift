//
//  ServiceWrapper.swift
//  Feathers
//
//  Created by Brendan Conron on 5/21/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.NoError

final public class ServiceWrapper: ServiceType {

    public var path: String {
        return service.path
    }

    private weak var app: Feathers?

    private let service: ServiceType

    internal init(service: ServiceType) {
        self.service = service
    }

    final public func setup(app: Feathers, path: String) {
        self.app = app
    }

    final public func request(_ method: Service.Method) -> SignalProducer<Response, FeathersError> {
        guard let application = app else {
            return SignalProducer(error: FeathersError.unknown)
        }
        let reduceHooksClosure: (SignalProducer<HookObject, FeathersError>, Hook) -> SignalProducer<HookObject, FeathersError> = { acc, current in
            return acc.flatMap(.concat) { value in
                return current.run(with: value)
            }
        }
        let beforeHookObject = HookObject(type: .before, app: application, service: service, method: method)
        // Get all the hooks
        let beforeHooks = service.hooks(for: .before)?.hooks(for: method) ?? []
        let afterHooks = service.hooks(for: .after)?.hooks(for: method) ?? []
        let errorHooks = service.hooks(for: .error)?.hooks(for: method) ?? []
        let beforeChain = beforeHooks.reduce(SignalProducer(value: beforeHookObject), reduceHooksClosure)
        let chain = beforeChain.flatMap(.concat) { [weak self] hook -> SignalProducer<Response, FeathersError> in
            guard let vSelf = self else { return SignalProducer(error: .unknown) }
            if let _ = hook.result {
                let afterHookObject = hook.object(with: .after)
                let afterChain = afterHooks.reduce(SignalProducer(value: afterHookObject), reduceHooksClosure)
                return afterChain.flatMap(.concat) {
                    return $0.result != nil ? SignalProducer(value: $0.result!) : SignalProducer(error: .unknown)
                }
            } else if let error = hook.error {
                return SignalProducer(error: error)
            } else {
                return vSelf.service.request(method)
                    .flatMap(.latest) { response -> SignalProducer<Response, FeathersError> in
                        let afterHookObject = hook.object(with: .after).objectByAdding(result: response)
                        let afterChain = afterHooks.reduce(SignalProducer(value: afterHookObject), reduceHooksClosure)
                        return afterChain.flatMap(.concat) { value in
                            return value.result != nil ? SignalProducer(value: value.result!) : SignalProducer(error: .unknown)
                        }
                }
            }
        }
        return chain.flatMapError { [weak self] error -> SignalProducer<Response, FeathersError> in
            guard let vSelf = self else { return SignalProducer(error: .unknown) }
            let errorHookObject = HookObject(type: .error, app: application, service: vSelf, method: method).objectByAdding(error: error)
            let errorChain = errorHooks.reduce(SignalProducer(value: errorHookObject), reduceHooksClosure)
            return errorChain.flatMap(.concat) { hookObject -> SignalProducer<Response, FeathersError> in
                return hookObject.error != nil ? SignalProducer(error: hookObject.error!) : SignalProducer(error: error)
            }
        }
    }

    final public func hooks(before: Service.Hooks? = nil, after: Service.Hooks? = nil, error: Service.Hooks? = nil) {
        service.hooks(before: before, after: after, error: error)
    }

    final public func hooks(for kind: HookObject.Kind) -> Service.Hooks? {
        return service.hooks(for: kind)
    }

    public func on(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError> {
        return service.on(event: event)
    }

    public func once(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError> {
        return service.once(event: event)
    }

    public func off(event: Service.RealTimeEvent) {
        service.off(event: event)
    }


}
