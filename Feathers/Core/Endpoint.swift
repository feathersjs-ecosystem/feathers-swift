//
//  Endpoint.swift
//  Feathers
//
//  Created by Brendan Conron on 5/7/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation

/// Represents an endpoint on the server.
public final class Endpoint {

    /// Base url.
    public let baseURL: URL

    /// Endpoint path.
    public let path: String

    /// Service method.
    public let method: Service.Method

    /// Possible authentication token that can be attached to requests.
    public let accessToken: String?

    /// Application authentication configuration.
    public let authenticationConfiguration: AuthenticationConfiguration

    /// Creates an endpoint.
    ///
    /// - Parameters:
    ///   - baseURL: Base url.
    ///   - path: Endpoint path.
    ///   - method: Service method.
    ///   - accessToken: Authentication token.
    ///   - authenticationConfiguration: Authentication configuration.
    internal init(baseURL: URL, path: String, method: Service.Method, accessToken: String?, authenticationConfiguration: AuthenticationConfiguration) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.accessToken = accessToken
        self.authenticationConfiguration = authenticationConfiguration
    }

}
