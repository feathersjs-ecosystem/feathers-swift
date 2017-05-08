//
//  Endpoint.swift
//  Feathers
//
//  Created by Brendan Conron on 5/7/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import UIKit
import Alamofire

public final class Endpoint {

    public let url: String
    public let method: FeathersMethod
    public let parameters: [String: Any]?
    public let parameterEncoding: Alamofire.ParameterEncoding
    public let httpHeaderFields: [String: String]?

    internal init(url: String,
                method: FeathersMethod,
                parameters: [String: Any]? = nil,
                parameterEncoding: Alamofire.ParameterEncoding = URLEncoding.default,
                httpHeaderFields: [String: String]? = nil) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.parameterEncoding = parameterEncoding
        self.httpHeaderFields = httpHeaderFields
    }

    /// Convenience method for creating a new `Endpoint` with the same properties as the receiver, but with added parameters.
    internal func adding(newParameters: [String: Any]) -> Endpoint {
        return adding(parameters: newParameters)
    }

    /// Convenience method for creating a new `Endpoint` with the same properties as the receiver, but with added HTTP header fields.
    internal func adding(newHTTPHeaderFields: [String: String]) -> Endpoint {
        return adding(httpHeaderFields: newHTTPHeaderFields)
    }

    /// Convenience method for creating a new `Endpoint` with the same properties as the receiver, but with another parameter encoding.
    internal func adding(newParameterEncoding: Alamofire.ParameterEncoding) -> Endpoint {
        return adding(parameterEncoding: newParameterEncoding)
    }

    /// Convenience method for creating a new `Endpoint`, with changes only to the properties we specify as parameters
    open func adding(parameters: [String: Any]? = nil, httpHeaderFields: [String: String]? = nil, parameterEncoding: Alamofire.ParameterEncoding? = nil)  -> Endpoint {
        let newParameters = add(parameters: parameters)
        let newHTTPHeaderFields = add(httpHeaderFields: httpHeaderFields)
        let newParameterEncoding = parameterEncoding ?? self.parameterEncoding
        return Endpoint(url: url, method: method, parameters: newParameters, parameterEncoding: newParameterEncoding, httpHeaderFields: newHTTPHeaderFields)
    }

    fileprivate func add(parameters: [String: Any]?) -> [String: Any]? {
        guard let unwrappedParameters = parameters, unwrappedParameters.isEmpty == false else {
            return self.parameters
        }

        var newParameters = self.parameters ?? [:]
        unwrappedParameters.forEach { key, value in
            newParameters[key] = value
        }
        return newParameters
    }

    fileprivate func add(httpHeaderFields headers: [String: String]?) -> [String: String]? {
        guard let unwrappedHeaders = headers, unwrappedHeaders.isEmpty == false else {
            return self.httpHeaderFields
        }

        var newHTTPHeaderFields = self.httpHeaderFields ?? [:]
        unwrappedHeaders.forEach { key, value in
            newHTTPHeaderFields[key] = value
        }
        return newHTTPHeaderFields
    }

}

extension Endpoint {

    internal var urlRequest: URLRequest? {
        guard let requestURL = Foundation.URL(string: url) else { return nil }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.httpMethod.rawValue
        request.allHTTPHeaderFields = httpHeaderFields

        return try? parameterEncoding.encode(request, with: parameters)
    }

}
