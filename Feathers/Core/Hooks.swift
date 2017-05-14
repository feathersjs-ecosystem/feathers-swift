//
//  Hooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/13/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

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
    public let service: Service

    /// The service method.
    public let method: Service.Method

    /// The service method parameters.
    public var parameters: [String: Any]?

    /// The request data.
    public var data: [String: Any]?

    /// The id (for get, remove, update and patch).
    public var id: String?

    /// Error that can be set which will stop the hook processing chain and run a special chain of error hooks.
    public var error: Error?

    /// Result of a successful method call, only in after hooks.
    public var result: Response?

    public init(
        type: Kind,
        app: Feathers,
        service: Service,
        method: Service.Method) {
        self.type = type
        self.app = app
        self.service = service
        self.method = method
    }

}

public extension HookObject {

    public func objectByAdding(result: Response) -> HookObject {
        var object = self
        object.result = result
        return object
    }

    public func objectByAdding(error: Error) -> HookObject {
        var object = self
        object.error = error
        return object
    }

    func object(with type: Kind) -> HookObject {
        var object = HookObject(type: type, app: app, service: service, method: method)
        object.parameters = parameters
        object.data = data
        object.id = id
        object.error = error
        object.result = result
        return object
    }

}

public typealias HookNext = (HookObject) -> ()

public protocol Hook {
    func run(with hookObject: HookObject, _ next: @escaping (HookObject) -> ())
}
