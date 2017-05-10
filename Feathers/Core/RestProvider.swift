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

    public final func setup() {}

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

    public final func authenticate(_ path: String, credentials: [String: Any], _ completion: @escaping FeathersCallback) {
        Alamofire.request(baseURL.appendingPathComponent(path), method: .post, parameters: credentials, encoding: URLEncoding.httpBody)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

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

public extension Service.Method {

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

    var parameters: [String: Any]? {
        switch self {
        case .find(let parameters): return parameters
        case .get(_, let parameters): return parameters
        case .create(_, let parameters): return parameters
        case .update(_, _, let parameters): return parameters
        case .patch(_, _, let parameters): return parameters
        case .remove(_, let parameters): return parameters
        }
    }

    var data: [String: Any]? {
        switch self {
        case .create(let data, _): return data
        case .update(_, let data, _): return data
        case .patch(_, let data, _): return data
        default: return nil
        }
    }

}


internal extension Endpoint {

    internal var url: URL {
        var url = baseURL.appendingPathComponent(path)
        switch method {
        case .get(let id, _),
             .update(let id, _, _),
             .patch(let id, _, _),
             .remove(let id, _):
            url = url.appendingPathComponent(id)
        default: break
        }
        url = method.parameters != nil ? (url.URLByAppendingQueryParameters(parameters: method.parameters!) ?? url) : url
        return url
    }

}

