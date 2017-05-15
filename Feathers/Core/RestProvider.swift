//
//  RestProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import Alamofire
import enum Result.Result

final public class RestProvider: Provider {

    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public final func setup(app: Feathers) {}

    public func request(endpoint: Endpoint, _ completion: @escaping FeathersCallback) {
        let request = buildRequest(from: endpoint)
        Alamofire.request(request)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

    public func request(hookObject: HookObject, _ next: @escaping HookNext) {

    }

    public final func authenticate(_ path: String, credentials: [String: Any], _ completion: @escaping FeathersCallback) {
        authenticationRequest(path: path, method: .post, parameters: credentials, encoding: URLEncoding.httpBody, completion)
    }

    public func logout(path: String, _ completion: @escaping FeathersCallback) {
        authenticationRequest(path: path, method: .delete, parameters: nil, encoding: URLEncoding.default, completion)
    }

    /// Perform an authentication request.
    ///
    /// - Parameters:
    ///   - path: Authentication service path.
    ///   - method: HTTP method.
    ///   - parameters: Parameters.
    ///   - encoding: Parameter encoding.
    ///   - completion: Completion block.
    private func authenticationRequest(path: String, method: HTTPMethod, parameters: [String: Any]?, encoding: ParameterEncoding, _ completion: @escaping FeathersCallback) {
        Alamofire.request(baseURL.appendingPathComponent(path), method: method, parameters: parameters, encoding: encoding)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

    /// Handle the data response from an Alamofire request.
    ///
    /// - Parameter dataResponse: Alamofire data response.
    /// - Returns: Result with an error or a successful response.
    private func handleResponse(_ dataResponse: DataResponse<Any>) -> Result<Response, FeathersError> {
        // If the status code maps to a feathers error code, return that error.
        if let statusCode = dataResponse.response?.statusCode,
            let feathersError = FeathersError(statusCode: statusCode) {
            return .failure(feathersError)
        } else if let error = dataResponse.error {
            // If the data response has an error, wrap it and return it.
            return .failure(FeathersError(error: error))
        } else if let value = dataResponse.value {
            // If the response value is an array, there is no pagination.
            if let jsonArray = value as? [Any] {
                return .success(Response(pagination: nil, data: .jsonArray(jsonArray)))
            } else if let jsonDictionary = value as? [String: Any] {
                // If the value is a json dictionary, it can be one of two cases:
                // 1: The json object is wrapping the data with pagination information
                // 2: The response is returning an object right from the server i.e. a GET, POST, etc
                if let skip = jsonDictionary["skip"] as? Int,
                    let limit = jsonDictionary["limit"] as? Int,
                    let total = jsonDictionary["total"] as? Int,
                    let dataArray = jsonDictionary["data"] as? [Any] {
                    return .success(Response(pagination: Pagination(total: total, limit: limit, skip: skip), data: .jsonArray(dataArray)))
                } else {
                    return .success(Response(pagination: nil, data: .jsonObject(value)))
                }
            }
        }
        return .failure(.unknown)
    }

    /// Build a request from the given endpiont.
    ///
    /// - Parameter endpoint: Request endpoint.
    /// - Returns: Request object.
    private func buildRequest(from endpoint: Endpoint) -> URLRequest {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = endpoint.method.httpMethod.rawValue
        if let accessToken = endpoint.accessToken {
            urlRequest.allHTTPHeaderFields = [endpoint.authenticationConfiguration.header: accessToken]
        }
        urlRequest.httpBody = endpoint.method.data != nil ? try? JSONSerialization.data(withJSONObject: endpoint.method.data!, options: []) : nil
        return urlRequest
    }

}

fileprivate extension Service.Method {

    fileprivate var httpMethod: HTTPMethod {
        switch self {
        case .find: return .get
        case .get: return .get
        case .create: return .post
        case .update: return .put
        case .patch: return .patch
        case .remove: return .delete
        }
    }
    
}


internal extension Endpoint {

    internal var url: URL {
        var url = baseURL.appendingPathComponent(path)
        switch method {
        case .get(let id, _):
            url = url.appendingPathComponent(id)
        case .update(let id, _, _),
             .patch(let id, _, _),
             .remove(let id, _):
            url = id != nil ? url.appendingPathComponent(id!) : url
        default: break
        }
        url = method.parameters != nil ? (url.URLByAppendingQueryParameters(parameters: method.parameters!) ?? url) : url
        return url
    }

}

