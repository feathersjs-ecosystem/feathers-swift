//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod

public enum FeathersMethod {

    case find(parameters: [String: Any]?)
    case get(id: String, parameters: [String: Any]?)
    case create(data: [String: Any], parameters: [String: Any]?)
    case update(id: String, data: [String: Any], parameters: [String: Any]?)
    case patch(id: String, data: [String: Any], paramters: [String: Any]?)
    case remove(id: String, parameters: [String: Any]?)

    public var httpMethod: HTTPMethod {
        switch self {
        case .find: return .get
        case .get: return .get
        case .create: return .post
        case .update: return .put
        case .patch: return .patch
        case .remove: return .delete
        }
    }

    var stringMethod: String {
        switch self {
        case .find: return "find"
        case .get: return "get"
        case .create: return "create"
        case .update: return "update"
        case .patch: return "patch"
        case .remove: return "delete"
        }
    }
}

final public class Service {

    public let provider: Provider
    public let path: String
    private weak var storage: AuthenticationStorage?
    private let authOptions: AuthenticationOptions

    internal init(provider: Provider, path: String, storage: AuthenticationStorage, authOptions: AuthenticationOptions) {
        self.provider = provider
        self.path = path
        self.storage = storage
        self.authOptions = authOptions
    }

    public func request(_ method: FeathersMethod, _ completion: @escaping FeathersCallback) {
        var mutableParameters: [String: Any]? = nil
        var url = provider.baseURL.appendingPathComponent(path)
        var encoding: ParameterEncoding = URLEncoding.default
        switch method {
        case .find(let parameters):
            mutableParameters = parameters
        case .get(let id, let parameters):
            url = url.appendingPathComponent(id)
            url = url.URLByAppendingQueryParameters(parameters: parameters ?? [:]) ?? url
        case .create(let data, let parameters):
            url = url.URLByAppendingQueryParameters(parameters: parameters ?? [:]) ?? url
            mutableParameters = data
            encoding = JSONEncoding.default
        case .update(let id, let data, let parameters):
            url = url.appendingPathComponent(id)
            url = url.URLByAppendingQueryParameters(parameters: parameters ?? [:]) ?? url
            encoding = JSONEncoding.default
            mutableParameters = data
        case .patch(let id, let data, let parameters):
            url = url.appendingPathComponent(id)
            url = url.URLByAppendingQueryParameters(parameters: parameters ?? [:]) ?? url
            mutableParameters = data
            encoding = JSONEncoding.default
        case .remove(let id, let parameters):
            url = url.appendingPathComponent(id)
            url = url.URLByAppendingQueryParameters(parameters: parameters ?? [:]) ?? url
            encoding = JSONEncoding.default
        }

        var endpoint = Endpoint(url: url.absoluteString, method: method, parameters: mutableParameters, parameterEncoding: encoding, httpHeaderFields: [:])

        if let storage = storage,
        let accessToken = storage.accessToken {
            endpoint = endpoint.adding(newHTTPHeaderFields: [authOptions.header: accessToken])
        }
        provider.request(endpoint: endpoint, completion)
    }

}
