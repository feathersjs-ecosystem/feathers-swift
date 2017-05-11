//
//  SocketProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import SocketIO
import Foundation
import Result

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
            var data: [String: Any] = [:]
            for option in client.config {
                if case let .connectParams(params) = option {
                    data = params
                    break
                }
            }
            if let oldAccessToken = data[endpoint.authenticationConfiguration.header] as? String, oldAccessToken != accessToken {
                data[endpoint.authenticationConfiguration.header] = accessToken
                client.config.insert(.connectParams(data), replacing: true)
                client.reconnect()
            }
        }
        let emitPath = "\(endpoint.path)::\(endpoint.method.socketRequestPath)"
        if client.status == .connecting {
            client.on("connect") { [weak self] data, ack in
                self?.client.emitWithAck(emitPath, endpoint.method.socketData).timingOut(after: self?.timeout ?? 5) { data in
                    print(data)
                }
            }
        } else if client.status == .disconnected || client.status == .notConnected {
            client.on("connect") { [weak self] data, ack in
                self?.client.emitWithAck(emitPath, endpoint.method.socketData).timingOut(after: self?.timeout ?? 5) { data in
                    print(data)
                }
            }
            client.connect()
        } else {
            client.emitWithAck(emitPath, endpoint.method.socketData).timingOut(after: timeout) { data in
                print(data)
            }
        }
    }

    public func authenticate(_ path: String, credentials: [String : Any], _ completion: @escaping FeathersCallback) {
        if client.status == .connecting {
            client.on("connect") { [weak self] data, ack in
                self?.client.emitWithAck("authenticate", credentials).timingOut(after: self?.timeout ?? 5) { data in
                    print(data)
                }
            }
        } else if client.status == .disconnected || client.status == .notConnected {
            client.on("connect") { [weak self] data, ack in
                self?.client.emitWithAck("authenticate", credentials).timingOut(after: self?.timeout ?? 5) { data in
                    print(data)
                }
            }
            client.connect()
        } else {
            client.emitWithAck("authenticate", credentials).timingOut(after: timeout) { data in
                print(data)
            }
        }
    }

//    private func handleResponseData(data: [Any]) -> Result<Response, FeathersError> {
//        if let noAck = data.first as? String, noAck == "NO ACK" {
//            return .failure(.notFound)
//        }
//    }

}

extension Service.Method {

    var socketRequestPath: String {
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
