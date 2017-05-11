//
//  SocketProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import SocketIO
import Foundation

public final class SocketProvider: Provider {

    public let baseURL: URL

    private let client: SocketIOClient
    private let timeout: Int

    public init(client: SocketIOClient, timeout: Int = 5) {
        self.baseURL = client.socketURL
        self.client = client
        self.timeout = timeout
    }

    public func setup() {
        client.connect(timeoutAfter: timeout) {
            print("feathers socket failed to connect")
        }
    }

    public func request(endpoint: Endpoint, _ completion: @escaping FeathersCallback) {
        // If there's an access token, we have to "inject" it into the existing config.
        if let accessToken = endpoint.accessToken {
            var config: SocketIOClientConfiguration = []
            for option in client.config {
                if case var .connectParams(data) = option {
                    data[endpoint.authenticationConfiguration.header] = accessToken
                    config.insert(.connectParams(data))
                } else {
                    config.insert(option)
                }
            }
            client.config = config
        }
        client.emitWithAck("\(endpoint.path)::\(endpoint.method.socketEvent)", endpoint.method.socketData).timingOut(after: timeout) { data in
            print(data)
        }
    }

    public func authenticate(_ path: String, credentials: [String : Any], _ completion: @escaping FeathersCallback) {
        client.emitWithAck("\(path)::create", credentials).timingOut(after: timeout) { data in
            print(data)
        }
    }
}

extension Service.Method {

    var socketEvent: String {
        switch self {
        case .find: return "find"
        case .get: return "get"
        case .create: return "create"
        case .update: return "update"
        case .patch: return "patch"
        case .remove: return "removed"
        }
    }

    var socketData: [SocketData] {
        switch self {
        case .find(let parameters):
            return [parameters ?? [:]]
        case .get(let id, let parameters),
             .remove(let id, let parameters):
            return [id, parameters ?? [:]]
        case .create(let data, let parameters):
            return [data, parameters ?? [:]]
        case .update(let id, let data, let parameters),
             .patch(let id, let data, let parameters):
            return [id, data, parameters ?? [:]]
        }
    }

}
