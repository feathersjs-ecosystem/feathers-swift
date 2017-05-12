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

    func request(endpoint: Endpoint, _ completion: @escaping FeathersCallback)

    /// Authenticate the provider.
    ///
    /// - Parameters:
    ///   - path: Authentication path.
    ///   - credentials: Credentials object for authentication.
    ///   - completion: Completion block.
    func authenticate(_ path: String, credentials: [String: Any], _ completion: @escaping FeathersCallback)

}

public protocol RealTimeProvider: Provider {

    func on(event: String, callback:() -> ())
    func off(event: String, callback: () -> ())

}
