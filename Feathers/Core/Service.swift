//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

/// Represents a subclassable Feather's service. `Service` is not to be 
/// used by itself; it's an abstract base class for all other service to inherit from.
/// To use a service, see `ProviderService` or create your own!
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

        case find(query: Query?)
        case get(id: String, query: Query?)
        case create(data: [String: Any], query: Query?)
        case update(id: String?, data: [String: Any], query: Query?)
        case patch(id: String?, data: [String: Any], query: Query?)
        case remove(id: String?, query: Query?)

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

        /// True if the object contains any hooks, false otherwise.
        public var isEmpty: Bool {
            return all.isEmpty
            && find.isEmpty
            && get.isEmpty
            && create.isEmpty
            && update.isEmpty
            && patch.isEmpty
            && remove.isEmpty
        }

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

    // MARK: Real-time

    /// A real time event that `RealTimeProvider`s can emit.
    ///
    /// - created: Entity has been created.
    /// - updated: Entity has been updated.
    /// - patched: Entity has been patched.
    /// - removed: Entity has been removed.
    public enum RealTimeEvent: String {
        
        case created
        case updated
        case patched
        case removed

    }

    /// Weak reference to the main feathers app.
    private(set) public weak var app: Feathers?

    // MARK: - Initialization

    public init() {}

    // MARK: - ServiceType

    /// The service path.
    private(set) public var path: String = ""

    open func setup(app: Feathers, path: String) {
        self.app = app
        self.path = path
    }

    open func request(_ method: Service.Method) -> SignalProducer<Response, AnyFeathersError> {
        fatalError("Must be overriden by a subclass")
    }

    final public func before(_ hooks: Hooks) {
        beforeHooks = beforeHooks.add(hooks: hooks)
    }

    final public func after(_ hooks: Hooks) {
        afterHooks = afterHooks.add(hooks: hooks)
    }

    final public func error(_ hooks: Hooks) {
        errorHooks = errorHooks.add(hooks: hooks)
    }

    final public func hooks(for kind: HookObject.Kind) -> Service.Hooks? {
        switch kind {
        case .before: return beforeHooks.isEmpty ? nil : beforeHooks
        case .after: return afterHooks.isEmpty ? nil : afterHooks
        case .error: return errorHooks.isEmpty ? nil : errorHooks
        }
    }

    public func on(event: RealTimeEvent) -> Signal<[String: Any], NoError> {
        // no-op
        return .empty
    }

    public func once(event: RealTimeEvent) -> Signal<[String: Any], NoError> {
        return .empty
    }

    public func off(event: RealTimeEvent) {
        // no-op
    }

    public var supportsRealtimeEvents: Bool {
        return false
    }

}

internal extension Service.Hooks {

    /// Internal extension for grabbing all the hooks for a given method.
    ///
    /// - Parameter method: Service method.
    /// - Returns: A list of hooks registered for that service method.
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
