//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

open class Service {

    public enum Method {

        case find(parameters: [String: Any]?)
        case get(id: String, parameters: [String: Any]?)
        case create(data: [String: Any], parameters: [String: Any]?)
        case update(id: String, data: [String: Any], parameters: [String: Any]?)
        case patch(id: String, data: [String: Any], paramters: [String: Any]?)
        case remove(id: String, parameters: [String: Any]?)

    }

    public enum RealTimeEvent: CustomStringConvertible {

        case created
        case updated
        case patched
        case removed

        public var description: String {
            switch self {
            case .created: return "created"
            case .updated: return "updated"
            case .patched: return "patched"
            case .removed: return "removed"
            }
        }

    }

    public let provider: Provider
    public let path: String
    private weak var storage: AuthenticationStorage?
    private let authenticationConfig: AuthenticationConfiguration


    internal init(provider: Provider, path: String, storage: AuthenticationStorage, authenticationConfig: AuthenticationConfiguration) {
        self.provider = provider
        self.path = path
        self.storage = storage
        self.authenticationConfig = authenticationConfig
    }

    public func request(_ method: Service.Method, _ completion: @escaping FeathersCallback) {
        var endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: nil, authenticationConfiguration: authenticationConfig)
        if let storage = storage,
        let accessToken = storage.accessToken {
            endpoint = Endpoint(baseURL: provider.baseURL, path: path, method: method, accessToken: accessToken, authenticationConfiguration: authenticationConfig)
        }
        provider.request(endpoint: endpoint, completion)
    }

    public func on(event: RealTimeEvent, _ callback: @escaping ([String: Any]) -> ()) {
        if let realTimeProvider = provider as? RealTimeProvider {
            realTimeProvider.on(event: "\(path) \(event.description)", callback: { object in
                callback(object)
            })
        }
    }

    public func off(event: RealTimeEvent) {
        if let realTimeProvider = provider as? RealTimeProvider {
            realTimeProvider.off(event: "\(path) \(event.description)")
        }
    }

}


