//
//  RestProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

final public class RestProvider: Provider {

    public let baseURL: URL

    private var responseHandleClosure: (DataResponse<Any>) -> (((Response) -> (), (Error) -> ()) -> ()) = { dataResponse in
        return { fulfill, reject in
            if let statusCode = dataResponse.response?.statusCode,
            let feathersError = FeathersError(statusCode: statusCode) {
                reject(feathersError)
            } else if let error = dataResponse.error {
                reject(FeathersError(error: error))
            } else if let value = dataResponse.value {
                if let jsonArray = value as? [Any] {
                    // not paginated
                    fulfill(Response(pagination: nil, data: .jsonArray(jsonArray)))
                } else if let jsonDictionary = value as? [String: Any] {
                    if let skip = jsonDictionary["skip"] as? Int,
                        let limit = jsonDictionary["limit"] as? Int,
                        let total = jsonDictionary["total"] as? Int,
                        let dataArray = jsonDictionary["data"] as? [Any] {
                        fulfill(Response(pagination: Pagination(total: total, limit: limit, skip: skip), data: .jsonArray(dataArray)))
                    } else {
                        fulfill(Response(pagination: nil, data: .jsonObject(value)))
                    }
                } else {
                    reject(FeathersError.unknown)
                }
            } else {
                reject(FeathersError.unknown)
            }
        }
    }

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public final func setup() {}

    public final func authenticate(_ path: String, credentials: [String: Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            Alamofire.request(baseURL.appendingPathComponent(path), method: .post, parameters: credentials, encoding: URLEncoding.httpBody)
                .validate()
                .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                    guard let vSelf = self else { return }
                    vSelf.responseHandleClosure(response)(fulfill, reject)
            }
        }
    }

    public final func find(_ path: String, parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            Alamofire.request(baseURL.appendingPathComponent(path), method: .get, parameters: parameters, encoding: URLEncoding.queryString)
                .validate()
                .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                    guard let vSelf = self else { return }
                    vSelf.responseHandleClosure(response)(fulfill, reject)
            }
        }
    }

    public final func get(_ path: String, id: String, parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            Alamofire.request(baseURL.appendingPathComponent(path).appendingPathComponent(id), method: .get, parameters: parameters, encoding: URLEncoding.queryString)
                .validate()
                .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                    guard let vSelf = self else { return }
                        vSelf.responseHandleClosure(response)(fulfill, reject)
            }
        }
    }

    public final func create(_ path: String, data: [String : Any], parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            let queryURL = baseURL.appendingPathComponent(path).URLByAppendingQueryParameters(parameters: parameters)
            var mutableRequest = URLRequest(url: queryURL!)
            mutableRequest.httpMethod = "POST"
            mutableRequest.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
            Alamofire.request(mutableRequest)
                .validate()
                .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                    guard let vSelf = self else { return }
                        vSelf.responseHandleClosure(response)(fulfill, reject)
            }

        }
    }

    public final func update(_ path: String, id: String, data: [String : Any], parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
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
                    vSelf.responseHandleClosure(response)(fulfill, reject)
            }
        }
    }

    public final func patch(_ path: String, id: String, data: [String : Any], parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
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
                    vSelf.responseHandleClosure(response)(fulfill, reject)
            }
        }
    }

    public final func remove(_ path: String, id: String, parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            Alamofire.request(baseURL.appendingPathComponent(path).appendingPathComponent(id), method: .delete, parameters: parameters, encoding: URLEncoding.queryString)
                .validate()
                .response(responseSerializer: DataRequest.jsonResponseSerializer()) { [weak self] response in
                    guard let vSelf = self else { return }
                    vSelf.responseHandleClosure(response)(fulfill, reject)
            }
        }
    }

}
