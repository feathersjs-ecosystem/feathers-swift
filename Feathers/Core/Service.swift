//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

/// Represents a Feather's service. Used for making requests and in the case
/// of real-time providers, emitting real-time events.
open class Service {

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

    }

    /// Service before hooks.
    private var beforeHooks: Hooks?

    /// Servie after hooks.
    private var afterHooks: Hooks?

    /// Service error hooks.
    private var errorHooks: Hooks?


    /// Register hooks with the service.
    /// All hooks will get overriden regardless if they're supplied or not.
    ///
    /// - Parameters:
    ///   - before: Before hooks.
    ///   - after: After hooks.
    ///   - error: Error hooks.
    public func hooks(before: Hooks? = nil, after: Hooks? = nil, error: Hooks? = nil) {
        beforeHooks = before
        afterHooks = after
        errorHooks = error
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

    internal weak var app: Feathers?
    /// The application's provider.
    internal weak var provider: Provider?
    /// The service path.
    internal var path: String = ""

    /// Application auth storage mechanism.
    internal weak var storage: AuthenticationStorage?

    /// Application authentication configuration. Used in constructing endpoints.
    internal var authenticationConfig: AuthenticationConfiguration = AuthenticationConfiguration()

    /// Service initializer, internal to Feathers. You can't construct services yourself.
    ///
    /// - Parameters:
    ///   - app: Feathers application object.
    ///   - provider: Application provider.
    ///   - path: Service path.
    ///   - storage: Authentication storage mechanism passed in from the application.
    ///   - authenticationConfig: Application authentication configuration.
    required public init() {
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
    public func request(_ method: Service.Method, _ completion: @escaping FeathersCallback) {
        runBeforeHooks(with: method, completion)
    }

    /// Run any before hooks that were registered. Before hooks are the first step in the hook processing
    /// chain. If any error propogates in the chain, the error hooks are run and the request is skipped.
    /// Additionally, if the result is set in any before hook, the request is skipped.
    ///
    /// In the event the chain makes it to the sending the request, the resulting error/response is processed
    /// and the appropriate hook chain is called (error/after).
    ///
    /// - Parameters:
    ///   - method: Service method.
    ///   - completion: Completion block.
    private func runBeforeHooks(with method: Service.Method, _ completion: @escaping FeathersCallback) {
        guard let application = app else {
            completion(.unknown, nil)
            return
        }
        // Create our original hook object
        var beforeHookObject = HookObject(type: .before, app: application, service: self, method: method)
        beforeHookObject.parameters = method.parameters
        beforeHookObject.data = method.data
        beforeHookObject.id = method.id
        // Get a list of all the before hooks
        let beforeHooks = (self.beforeHooks?.all ?? []) + (self.beforeHooks?.hooks(for: method) ?? [])

        let beforeNext: HookNext = { [weak self] hookObject in
            guard let vSelf = self else { return }
            // If there's an error that came back, run all the error hooks and pass the completion block to it.
            if let error = hookObject.error as? FeathersError {
                vSelf.runErrorHooks(with: hookObject, error: error, completion)
            } else if let error = hookObject.error {
                vSelf.runErrorHooks(with: hookObject, error: .underlying(error), completion)
            } else if let response = hookObject.result {
                // If the result has already been set, skip calling the provider and run the after hooks
                vSelf.runAfterHooks(with: hookObject, result: response, completion)
            } else {
                // Otherwise construct an endpoint
                let endpoint = vSelf.constructEndpoint(from: method)
                vSelf.provider?.request(endpoint: endpoint) { error, response in
                    // If there's an error in the response, run the error hooks
                    if let error = error {
                        vSelf.runErrorHooks(with: beforeHookObject, error: error, completion)
                    } else if let response = response {
                        vSelf.runAfterHooks(with: beforeHookObject, result: response, completion)
                    } else {
                        completion(.unknown, nil)
                    }
                }
            }
        }
        runHookMiddleware(hooks: beforeHooks, withObject: beforeHookObject, beforeNext)
    }

    /// Run any after hooks that were registered. After hooks can run through to completion
    /// in which case the result is returned to the consumer or if an error is set, the after hooks will stop
    /// and run error hooks to completion instead.
    ///
    /// - Parameters:
    ///   - object: Hook object to modify.
    ///   - result: Result to attach to hook.
    ///   - completion: Completion block.
    private func runAfterHooks(with object: HookObject, result: Response, _ completion: @escaping FeathersCallback) {
        // Create the after hook
        let afterHookObject = object.objectByAdding(result: result).object(with: .after)
        let afterHooks = (self.afterHooks?.all ?? []) + (self.afterHooks?.hooks(for: object.method) ?? [])
        let afterNext: HookNext = { [weak self] hookObject in
            guard let vSelf = self else { return }
            // If there's any type of error set on the hook, run the error hooks
            if let error = hookObject.error as? FeathersError {
                vSelf.runErrorHooks(with: object, error: error, completion)
            } else if let error = hookObject.error {
                vSelf.runErrorHooks(with: object, error: .underlying(error), completion)
            } else if let response = hookObject.result {
                // Otherwise when the chain is complete, pass the final result back to the consumer
                completion(nil, response)
            } else {
                completion(.unknown, nil)
            }
        }
        runHookMiddleware(hooks: afterHooks, withObject: afterHookObject, afterNext)
    }

    /// Run any error hooks that were registered. Error hooks are the final "chain" in hook processing. If run,
    /// they call the completion block and end the request chain.
    ///
    /// - Parameters:
    ///   - object: Hook object to modify.
    ///   - error: Error that occurred.
    ///   - completion: Completion block.
    private func runErrorHooks(with object: HookObject, error: FeathersError, _ completion: @escaping FeathersCallback) {
        let errorHookObject = object.object(with: .error).objectByAdding(error: error)
        let errorHooks = (self.errorHooks?.all ?? []) + (self.errorHooks?.hooks(for: object.method) ?? [])
        let errorNext: HookNext = { hookObject in
            if let error = hookObject.error as? FeathersError {
                completion(error, nil)
            } else if let error = hookObject.error {
                completion(.underlying(error), nil)
            } else {
                completion(.unknown, nil)
            }
        }
        runHookMiddleware(hooks: errorHooks, withObject: errorHookObject, errorNext)
    }

    /// Runs a list of middleware. Operates similar to how a promise chain works.
    ///
    /// - Parameters:
    ///   - hooks: List of hooks to run.
    ///   - object: Hook object that gets passed through.
    ///   - next: Next function.
    private func runHookMiddleware(hooks: [Hook], withObject object: HookObject, _ next: @escaping HookNext) {
        // If we've processed the list, finish and call next.
        guard !hooks.isEmpty else {
            next(object)
            return
        }
        // If the error has been set in the hook object, exit early from the processing chain.
        if object.type != .error {
            guard object.error == nil else {
                next(object)
                return
            }
        }
        // Get the next middleware to run.
        let hook = hooks.first!
        // Chop off the first element.
        let slice = Array(hooks[1..<hooks.count])
        hook.run(with: object) { [weak self] hookObject in
            // process the remaining hooks
            self?.runHookMiddleware(hooks: slice, withObject: hookObject, next)
        }
    }

    // MARK: - Helpers

    /// Given a service method, construct an endpoint.
    ///
    /// - Parameter method: Service method.
    /// - Returns: `Endpoint` object.
    private func constructEndpoint(from method: Service.Method) -> Endpoint {
        guard let provider = provider else { fatalError("provider must be given to the service before making requests") }
        var endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: nil, authenticationConfiguration: authenticationConfig)
        if let storage = storage,
            let accessToken = storage.accessToken {
            endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: accessToken, authenticationConfiguration: authenticationConfig)
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
        if let realTimeProvider = provider as? RealTimeProvider {
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
        if let realTimeProvider = provider as? RealTimeProvider {
            realTimeProvider.once(event: "\(path) \(event.rawValue)", callback: { object in
                callback(object)
            })
        }
    }

    /// Unregister for an event. Must be called to end the stream.
    ///
    /// - Parameter event: Real-time event to unregister from.
    public func off(event: RealTimeEvent) {
        if let realTimeProvider = provider as? RealTimeProvider {
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
        case .find: return find
        case .get: return get
        case .create: return create
        case .update: return update
        case .patch: return patch
        case .remove: return remove
        }
    }

}
