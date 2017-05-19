//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit

/// Represents a Feather's service. Used for making requests and in the case
/// of real-time providers, emitting real-time events.
final public class Service {

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
    public func hooks(before: Hooks? = nil, after: Hooks? = nil, error: Hooks? = nil) {
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

    // MARK: Real-time

    /// Callback for real-time events.
    public typealias RealTimeEventCallback = ([String: Any]) -> ()

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
    internal let path: String

    private weak var app: Feathers?
    
    /// Service initializer.
    ///
    /// - Parameter path: Service path.
    public init(path: String) {
        self.path = path
    }

    public func setup(app: Feathers) {
        self.app = app
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
    ///   - completion: Completion block.
    open func request(_ method: Service.Method) -> Promise<Response> {
        guard let application = app else {
            return Promise(error: FeathersError.unknown)
        }
        // Reduces an array of `Hook` objects into a single promise.
        let reduceHooksClosure: (Promise<HookObject>, Hook) -> Promise<HookObject> = { acc, current in
            return acc.then { value in
                return current.run(with: value)
            }
        }
        let beforeHookObject = HookObject(type: .before, app: application, service: self, method: method)
        // Get all the hooks
        let beforeHooks = self.beforeHooks.hooks(for: method)
        let afterHooks = self.afterHooks.hooks(for: method)
        let errorHooks = self.errorHooks.hooks(for: method)
        // Chain of hooks to run before the request
        let beforeChain = beforeHooks.reduce(Promise(value: beforeHookObject), reduceHooksClosure)
        let chain = beforeChain.then { [weak self] hook -> Promise<Response> in
            guard let vSelf = self else { return Promise(error: FeathersError.unknown) }
            // If the result has been set, skip the request and run the after hooks
            if let _ = hook.result?.value {
                let afterHookObject = hook.object(with: .after)
                let afterChain = afterHooks.reduce(Promise(value: afterHookObject), reduceHooksClosure)
                return afterChain.then {
                    return $0.result?.value != nil ? Promise(value: $0.result!.value!) : Promise(error: FeathersError.unknown)
                }
            } else {
                let endpoint = vSelf.constructEndpoint(from: hook.method)
                return application.provider.request(endpoint: endpoint).then { response in
                    let afterHookObject = hook.object(with: .after).objectByAdding(result: response)
                    let afterChain = afterHooks.reduce(Promise(value: afterHookObject), reduceHooksClosure)
                    return afterChain.then { value in
                        return value.result?.value != nil ? Promise(value: value.result!.value!) : Promise(error: FeathersError.unknown)
                    }
                }
            }
        }
        // If the chain errors at any point, run all the error hooks then send the final error
        return chain.recover { [weak self] error -> Promise<Response> in
            guard let vSelf = self else { throw error }
            var hook = HookObject(type: .error, app: application, service: vSelf, method: method)
            // Attach the error to the hook so the user can inspect what happened
            hook.result = error as? FeathersError != nil ? .failure(error as! FeathersError) : hook.result
            let errorChain = errorHooks.reduce(Promise(value: hook), reduceHooksClosure)
            return errorChain.then { hook -> Promise<Response> in
                return hook.result?.error != nil ? Promise(error: hook.result!.error!) : Promise(error: error)
            }
        }
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

    // MARK: - Real-Time

    /// Register to listen for a real-time event.
    ///
    /// - Parameters:
    ///   - event: Event to listen for.
    ///   - callback: Event callback.
    ///
    /// - Note: If the provider doesn't conform to `RealTimeProvider`, nothing will happen.
    public func on(event: RealTimeEvent, _ callback: @escaping RealTimeEventCallback) {
        if let realTimeProvider = app?.provider as? RealTimeProvider {
            realTimeProvider.on(event: "\(path) \(event.rawValue)", callback: { object in
                callback(object)
            })
        }
    }

    /// Register to listen for an event once and only once.
    ///
    /// - Parameters:
    ///   - event: Event to listen for.
    ///   - callback: Single-use-callback.
    public func once(event: RealTimeEvent, _ callback: @escaping RealTimeEventCallback) {
        if let realTimeProvider = app?.provider as? RealTimeProvider {
            realTimeProvider.once(event: "\(path) \(event.rawValue)", callback: { object in
                callback(object)
            })
        }
    }

    /// Unregister for an event. Must be called to end the stream.
    ///
    /// - Parameter event: Real-time event to unregister from.
    public func off(event: RealTimeEvent) {
        if let realTimeProvider = app?.provider as? RealTimeProvider {
            realTimeProvider.off(event: "\(path) \(event.rawValue)")
        }
    }

}


public extension Service.Method {

    public var id: String? {
        switch self {
        case .get(let id, _): return id
        case .update(let id, _, _),
             .patch(let id, _, _): return id
        case .remove(let id, _): return id
        default: return nil
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .find(let parameters): return parameters
        case .get(_, let parameters): return parameters
        case .create(_, let parameters): return parameters
        case .update(_, _, let parameters): return parameters
        case .patch(_, _, let parameters): return parameters
        case .remove(_, let parameters): return parameters
        }
    }

    public var data: [String: Any]? {
        switch self {
        case .create(let data, _): return data
        case .update(_, let data, _): return data
        case .patch(_, let data, _): return data
        default: return nil
        }
    }

}

fileprivate extension Service.Hooks {

    fileprivate func hooks(for method: Service.Method) -> [Hook] {
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
