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
public final class Service {

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

    /// Service hooks
    public struct Hooks {

        /// Hooks for all service methods.
        public let all: [HookFunction]

        /// Hooks for `.find` requests.
        public let find: [HookFunction]

        /// Hooks for `.get` requests.
        public let get: [HookFunction]

        /// Hooks for `.create` requests.
        public let create: [HookFunction]

        /// Hooks for `.update` requests.
        public let update: [HookFunction]

        /// Hooks for `.patch` requests.
        public let patch: [HookFunction]

        /// Hooks for `.remove` requests.
        public let remove: [HookFunction]

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
            all: [HookFunction] = [],
            find: [HookFunction] = [],
            get: [HookFunction] = [],
            create: [HookFunction] = [],
            update: [HookFunction] = [],
            patch: [HookFunction] = [],
            remove: [HookFunction] = []) {
            self.all = all
            self.find = find
            self.get = get
            self.create = create
            self.update = update
            self.patch = patch
            self.remove = remove
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

    /// The application's provider.
    public let provider: Provider
    /// The service path.
    public let path: String

    /// Application auth storage mechanism.
    private weak var storage: AuthenticationStorage?

    /// Application authentication configuration. Used in constructing endpoints.
    private let authenticationConfig: AuthenticationConfiguration

    /// Service initializer, internal to Feathers. You can't construct services yourself.
    ///
    /// - Parameters:
    ///   - provider: Application provider.
    ///   - path: Service path.
    ///   - storage: Authentication storage mechanism passed in from the application.
    ///   - authenticationConfig: Application authentication configuration.
    internal init(provider: Provider, path: String, storage: AuthenticationStorage, authenticationConfig: AuthenticationConfiguration) {
        self.provider = provider
        self.path = path
        self.storage = storage
        self.authenticationConfig = authenticationConfig
    }

    /// Request data from the server. The service creates an endpoint and passes it to the provider.
    ///
    /// - Parameters:
    ///   - method: Service method to request for.
    ///   - completion: Completion block.
    public func request(_ method: Service.Method, _ completion: @escaping FeathersCallback) {
        var endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: nil, authenticationConfiguration: authenticationConfig)
        if let storage = storage,
        let accessToken = storage.accessToken {
            endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: accessToken, authenticationConfiguration: authenticationConfig)
        }
        provider.request(endpoint: endpoint, completion)
    }

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

    /// Unregister for an event. Must be called to end the stream.
    ///
    /// - Parameter event: Real-time event to unregister from.
    public func off(event: RealTimeEvent) {
        if let realTimeProvider = provider as? RealTimeProvider {
            realTimeProvider.off(event: "\(path) \(event.rawValue)")
        }
    }

}


