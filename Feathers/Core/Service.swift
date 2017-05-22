//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

/// Represents a Feather's service. Used for making requests and in the case
/// of real-time providers, emitting real-time events.
open class Service: ServiceType {

    /// Service methods.
    ///
    /// - find: Retrieves a list of all resources from the service, can be filtered.
    /// - get:  Retrieves a single resource with the given id from the service.
    /// - create: Creates a new resource with data.
    /// - update: Replaces the resource identified by id with data. 
    /// `id` may be nil when updating a list, indicating multiple entities with query parameters.
    /// - patch: Merges the existing data of the resource identified by id with the new data.
    /// `id` may be nil when patching a list, indicating multiple entities with query parameters.
    /// - remove: Removes the resource with id. `id` may be nil when deleting a list,
    /// indicating multiple entities with query parameters.
    public enum Method {

        case find(parameters: [String: Any]?)
        case get(id: String, parameters: [String: Any]?)
        case create(data: [String: Any], parameters: [String: Any]?)
        case update(id: String?, data: [String: Any], parameters: [String: Any]?)
        case patch(id: String?, data: [String: Any], parameters: [String: Any]?)
        case remove(id: String?, parameters: [String: Any]?)

    }

    // MARK: - Hooks

    /// Service hooks that can be registered with the service.
    public struct Hooks {

        /// Hooks for all service methods.
        public let all: [Hook]

        /// Hooks for `.find` requests.
        public let find: [Hook]

        /// Hooks for `.get` requests.
        public let get: [Hook]

        /// Hooks for `.create` requests.
        public let create: [Hook]

        /// Hooks for `.update` requests.
        public let update: [Hook]

        /// Hooks for `.patch` requests.
        public let patch: [Hook]

        /// Hooks for `.remove` requests.
        public let remove: [Hook]

        /// Service hooks initializer.
        ///
        /// - Parameters:
        ///   - kind: The kind of hooks.
        ///   - all: Hooks to run on all service methods.
        ///   - find: Find hooks.
        ///   - get: Get hooks.
        ///   - create: Create hooks.
        ///   - update: Update hooks.
        ///   - patch: Patch hooks.
        ///   - remove: Remove hooks.
        public init(
            all: [Hook] = [],
            find: [Hook] = [],
            get: [Hook] = [],
            create: [Hook] = [],
            update: [Hook] = [],
            patch: [Hook] = [],
            remove: [Hook] = []) {
            self.all = all
            self.find = find
            self.get = get
            self.create = create
            self.update = update
            self.patch = patch
            self.remove = remove
        }

        /// Create a new hook object by merging hooks together.
        ///
        /// - Parameter hooks: Hooks to add.
        /// - Returns: New `Hooks` object.
        public func add(hooks: Hooks) -> Hooks {
            return Hooks(
                all: all + hooks.all,
                find: find + hooks.find,
                get: get + hooks.get,
                create: create + hooks.create,
                update: update + hooks.update,
                patch: patch + hooks.patch,
                remove: remove + hooks.remove)
        }

    }

    /// Service before hooks.
    private var beforeHooks = Hooks()

    /// Servie after hooks.
    private var afterHooks = Hooks()

    /// Service error hooks.
    private var errorHooks = Hooks()

    /// Register hooks with the service.
    /// Hooks get added with each successive use, not overridden.
    ///
    /// - Parameters:
    ///   - before: Before hooks.
    ///   - after: After hooks.
    ///   - error: Error hooks.
    final public func hooks(before: Hooks? = nil, after: Hooks? = nil, error: Hooks? = nil) {
        if let before = before {
            beforeHooks = beforeHooks.add(hooks: before)
        }
        if let after = after {
            afterHooks = afterHooks.add(hooks: after)
        }
        if let error = error {
            errorHooks = errorHooks.add(hooks: error)
        }
    }

    final public func hooks(for kind: HookObject.Kind) -> Service.Hooks? {
        switch kind {
        case .before: return beforeHooks
        case .after: return afterHooks
        case .error: return errorHooks
        }
    }

    // MARK: Real-time

    /// A real time event that `RealTimeProvider`s can emit.
    ///
    /// - created: Entity has been created.
    /// - updated: Entity has been updated.
    /// - patched: Entity has been patched.
    /// - removed: Entity has been removed.
    public enum RealTimeEvent: String {
        
        case created = "created"
        case updated = "updated"
        case patched = "patched"
        case removed = "removed"

    }

    /// The service path.
    private(set) public var path: String = ""

    private(set) public weak var app: Feathers?

    public init() {}

    open func setup(app: Feathers, path: String) {
        self.app = app
        self.path = path
    }

    /// Request data from the server.
    ///
    ///   The service will:
    ///   - run `all` before hooks then service method specifc before hooks
    ///   - make the request
    ///   - process the response and run `all` after hooks then service method specific after hooks
    ///
    ///   If at any point in the process a hook sets an error or the response sets the error, 
    ///   the error hooks will be run and the chain will complete.
    ///
    /// - Parameters:
    ///   - method: Service method to request for.
    ///
    /// - Returns a promise that emits a response.
    open func request(_ method: Service.Method) -> SignalProducer<Response, FeathersError> {
        fatalError("Must be overriden by a subclass")
    }

    // MARK: - Real-Time

    /// Register to listen for a real-time event.
    ///
    /// - Parameters:
    ///   - event: Event to listen for.
    ///   - callback: Event callback.
    ///
    /// - Note: If the provider doesn't conform to `RealTimeProvider`, nothing will happen.
    public func on(event: RealTimeEvent) -> Signal<[String: Any], NoError> {
        // no-op
        return .empty
    }

    /// Register to listen for an event once and only once.
    ///
    /// - Parameters:
    ///   - event: Event to listen for.
    ///   - callback: Single-use-callback.
    public func once(event: RealTimeEvent) -> Signal<[String: Any], NoError> {
        return .empty
    }

    /// Unregister for an event. Must be called to end the stream.
    ///
    /// - Parameter event: Real-time event to unregister from.
    public func off(event: RealTimeEvent) {
        // no-op
    }

}

internal extension Service.Hooks {

    internal func hooks(for method: Service.Method) -> [Hook] {
        switch method {
        case .find: return all + find
        case .get: return all + get
        case .create: return all + create
        case .update: return all + update
        case .patch: return all + patch
        case .remove: return all + remove
        }
    }

}
