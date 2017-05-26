//
//  Hooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/13/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

/// Hook object that gets passed through hook functions
public struct HookObject {

    /// Represents the kind of hook.
    ///
    /// - before: Hook is run before the request is made.
    /// - after: Hook is run after the request is made.
    /// - error: Runs when there's an error.
    public enum Kind {
        case before, after, error
    }

    /// The kind of hook.
    public let type: Kind

    /// Feathers application, used to retrieve other services.
    public let app: Feathers

    /// The service this hook currently runs on.
    public let service: ServiceType

    /// The service method.
    public var method: Service.Method

    public var result: Response?

    public var error: FeathersError?

    public init(
        type: Kind,
        app: Feathers,
        service: ServiceType,
        method: Service.Method) {
        self.type = type
        self.app = app
        self.service = service
        self.method = method
    }

}

public extension HookObject {

    /// Modify the hook object by adding a result.
    ///
    /// - Parameter result: Result to add.
    /// - Returns: Modified hook object.
    public func objectByAdding(result: Response) -> HookObject {
        var object = self
        object.result = result
        return object
    }

    /// Modify the hook object by attaching an error.
    ///
    /// - Parameter error: Error to attach.
    /// - Returns: Modified hook object.
    public func objectByAdding(error: FeathersError) -> HookObject {
        var object = self
        object.error = error
        return object
    }

    /// Create a new hook object with a new type.
    ///
    /// - Parameter type: New type.
    /// - Returns: A new hook object with copied over properties.
    func object(with type: Kind) -> HookObject {
        var object = HookObject(type: type, app: app, service: service, method: method)
        object.result = result
        return object
    }

}

/// Hook protocol.
public protocol Hook {

    /// Function that's called by the middleware system to run the hook.
    ///
    /// In order to modify the hook, a copy of it has to be made because
    /// Swift function parameters are `let` by default.
    ///
    /// - Parameters:
    ///   - hookObject: Hook object.
    /// - Returns: `SignalProducer` that emits the modified hook object or errors.
    func run(with hookObject: HookObject) -> SignalProducer<HookObject, AnyFeathersError>
}
