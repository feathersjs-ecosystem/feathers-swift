//
//  Service+ReactiveSwift.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift
import PromiseKit

extension Reactive where Base: Service {

    public func find(parameters: [String: Any]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.provider.find(base.path, parameters: parameters))
    }

    public func get(id: String, parameters: [String: Any] = [:]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.provider.get(base.path, id: id, parameters: parameters))
    }

    public func create(data: [String: Any], parameters: [String: Any] = [:]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.provider.create(base.path, data: data, parameters: parameters))
    }

    public func update(id: String, data: [String: Any], parameters: [String: Any] = [:]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.provider.update(base.path, id: id, data: data, parameters: parameters))
    }

    public func patch(id: String, data: [String: Any], parameters: [String: Any] = [:]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.provider.patch(base.path, id: id, data: data, parameters: parameters))
    }

    public func remove(id: String, parameters: [String: Any] = [:]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.provider.remove(base.path, id: id, parameters: parameters))
    }

}

extension SignalProducer where SignalProducer.Error: Swift.Error {

    static func from(promise: Promise<Value>) -> SignalProducer<Value, Error> {
        return SignalProducer { (observer: Observer<Value, Error>, disposable: Disposable) in
            promise.then { value -> () in
                observer.send(value: value)
                observer.sendCompleted()
            }.catch { (error: Swift.Error) -> Void in
                observer.send(error: error as! Error)
            }
        }
    }

}
