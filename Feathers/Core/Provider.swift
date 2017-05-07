//
//  Provider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

public typealias FeathersCallback = (FeathersError?, Response?) -> ()

/// Abstract interface for a provider.
public protocol Provider {

    var baseURL: URL { get }

    /// Used for any extra setup a provider needs. Called by the `Feathers` application.
    func setup()

    func request(path: String, method: FeathersMethod, _ completion: @escaping FeathersCallback)

    /// Authenticate the provider.
    ///
    /// - Parameters:
    ///   - path: Authentication path.
    ///   - credentials: Credentials object for authentication.
    ///   - completion: Completion block.
    func authenticate(_ path: String, credentials: [String: Any], _ completion: @escaping FeathersCallback)

    /// Find entities that match the given query parameters.
    ///
    /// - Parameters:
    ///   - path: Service path.
    ///   - parameters: Query parameters.
    ///   - completion: Completion block.
    func find(_ path: String, parameters: [String: Any], _ completion: @escaping FeathersCallback)

    /// Get a single entity by its id.
    ///
    /// - Parameters:
    ///   - path: Service path.
    ///   - id: Entity id.
    ///   - parameters: Additional query parameters to further filter the request.
    ///   - completion: Completion block.
    func get(_ path: String, id: String, parameters: [String: Any], _ completion: @escaping FeathersCallback)

    /// Create an entity.
    ///
    /// - Parameters:
    ///   - path: Service path.
    ///   - data: Entity data.
    ///   - parameters: Additional query parameters for restricting creation.
    ///   - completion: Completion block.
    func create(_ path: String, data: [String: Any], parameters: [String: Any], _ completion: @escaping FeathersCallback)

    /// Update (replace) an entity with the given id.
    ///
    /// - Parameters:
    ///   - path: Service path.
    ///   - id: Entity id.
    ///   - data: New entity data.
    ///   - parameters: Additional query parameters to further restrict update data.
    ///   - completion: Completion block.
    func update(_ path: String, id: String, data: [String: Any], parameters: [String: Any], _ completion: @escaping FeathersCallback)

    /// Patch an entity with the given id.
    ///
    /// - Parameters:
    ///   - path: Service path.
    ///   - id: Entity id.
    ///   - data: Data to patch the entity with.
    ///   - parameters: Additional query parameters to further restrict patch data.
    ///   - completion: Completion block.
    func patch(_ path: String, id: String, data: [String: Any], parameters: [String: Any], _ completion: @escaping FeathersCallback)

    /// Remove an entity with the given id.
    ///
    /// - Parameters:
    ///   - path: Service path.
    ///   - id: Entity id.
    ///   - parameters: Additional query parameters to further restrict deletion.
    ///   - completion: Completion block.
    func remove(_ path: String, id: String, parameters: [String: Any], _ completion: @escaping FeathersCallback)

}

extension Provider {
    
    public func request(path: String, method: FeathersMethod, _ completion: @escaping (FeathersError?, Response?) -> ()) {
        switch method {
        case .find(let parameters):
            find(path, parameters: parameters ?? [:], completion)
        case .get(let id, let parameters):
            get(path, id: id, parameters: parameters ?? [:], completion)
        case .create(let data, let parameters):
            create(path, data: data, parameters: parameters ?? [:], completion)
        case .update(let id, let data, let parameters):
            update(path, id: id, data: data, parameters: parameters ?? [:], completion)
        case .patch(let id, let data, let parameters):
            patch(path, id: id, data: data, parameters: parameters ?? [:], completion)
        case .remove(let id, let parameters):
            remove(path, id: id, parameters: parameters ?? [:], completion)
        }
    }

}
