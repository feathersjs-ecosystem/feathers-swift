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

    public final func authenticate(_ path: String, credentials: [String: Any], _ completion: @escaping FeathersCallback) {
        Alamofire.request(baseURL.appendingPathComponent(path), method: .post, parameters: credentials, encoding: URLEncoding.httpBody)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }

    }

    public final func find(_ path: String, parameters: [String : Any], _ completion: @escaping FeathersCallback) {
        Alamofire.request(baseURL.appendingPathComponent(path), method: .get, parameters: parameters, encoding: URLEncoding.queryString)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

    public final func get(_ path: String, id: String, parameters: [String : Any], _ completion: @escaping FeathersCallback) {
        Alamofire.request(baseURL.appendingPathComponent(path).appendingPathComponent(id), method: .get, parameters: parameters, encoding: URLEncoding.queryString)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

    public final func create(_ path: String, data: [String : Any], parameters: [String : Any], _ completion: @escaping FeathersCallback) {
        let queryURL = baseURL.appendingPathComponent(path).URLByAppendingQueryParameters(parameters: parameters)
        var mutableRequest = URLRequest(url: queryURL!)
        mutableRequest.httpMethod = "POST"
        mutableRequest.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        Alamofire.request(mutableRequest)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                print(self)
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

    public final func update(_ path: String, id: String, data: [String : Any], parameters: [String : Any], _ completion: @escaping FeathersCallback) {
        let queryURL = baseURL
            .appendingPathComponent(path)
            .appendingPathComponent(id)
            .URLByAppendingQueryParameters(parameters: parameters)
        var mutableRequest = URLRequest(url: queryURL!)
        mutableRequest.httpMethod = "PUT"
        mutableRequest.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        Alamofire.request(mutableRequest)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

    public final func patch(_ path: String, id: String, data: [String : Any], parameters: [String : Any], _ completion: @escaping FeathersCallback) {
        let queryURL = baseURL
            .appendingPathComponent(path)
            .appendingPathComponent(id)
            .URLByAppendingQueryParameters(parameters: parameters)
        var mutableRequest = URLRequest(url: queryURL!)
        mutableRequest.httpMethod = "PATCH"
        mutableRequest.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        Alamofire.request(mutableRequest)
            .validate()
            .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                guard let vSelf = self else { return }
                let result = vSelf.handleResponse(response)
                completion(result.error, result.value)
        }
    }

    public final func remove(_ path: String, id: String, parameters: [String : Any], _ completion: @escaping FeathersCallback) {
        Alamofire.request(baseURL.appendingPathComponent(path).appendingPathComponent(id), method: .delete, parameters: parameters, encoding: URLEncoding.queryString)
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

}
