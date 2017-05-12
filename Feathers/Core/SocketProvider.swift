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

    private let configuration: SocketIOClientConfiguration
    private let unauthenticatedClient: SocketIOClient
    private var authenticatedClient: SocketIOClient?

    private let timeout: Int

    public init(baseURL: URL, configuration: SocketIOClientConfiguration, timeout: Int = 5) {
        self.baseURL = baseURL
        self.configuration = configuration
        self.timeout = timeout
        unauthenticatedClient = SocketIOClient(socketURL: baseURL, config: configuration)
    }

    private func createClient(with url: URL, configuration: SocketIOClientConfiguration) -> SocketIOClient {
        return SocketIOClient(socketURL: url, config: configuration)
    }

    public func setup() {
        unauthenticatedClient.connect(timeoutAfter: timeout) {
            print("feathers socket failed to connect")
        }
    }

    public func request(endpoint: Endpoint, _ completion: @escaping FeathersCallback) {
        let emitPath = "\(endpoint.path)::\(endpoint.method.socketRequestPath)"
        if let accessToken = endpoint.accessToken, authenticatedClient == nil {
            authenticatedClient = spinUpAuthenticatedClient(with: accessToken, header: endpoint.authenticationConfiguration.header)
            authenticatedClient?.connect()
        }
        let client = authenticatedClient != nil ? authenticatedClient! : unauthenticatedClient
        if client.status == .connecting {
            client.once("connect") { [weak client = client, weak self] data, ack in
                client?.emitWithAck(emitPath, endpoint.method.socketData).timingOut(after: self?.timeout ?? 5) { data in
                    print(data)
                }
            }
        } else if client.status == .disconnected || client.status == .notConnected {
            client.once("connect") { [weak client = client, weak self] data, ack in
                client?.emitWithAck(emitPath, endpoint.method.socketData).timingOut(after: self?.timeout ?? 5) { data in
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
        if unauthenticatedClient.status == .connecting {
            unauthenticatedClient.once("connect") { [weak self] data, ack in
                self?.unauthenticatedClient.emitWithAck("authenticate", credentials).timingOut(after: self?.timeout ?? 5) { data in
                    print(data)
                }
            }
        } else if unauthenticatedClient.status == .disconnected || unauthenticatedClient.status == .notConnected {
            unauthenticatedClient.once("connect") { [weak self] data, ack in
                self?.unauthenticatedClient.emitWithAck("authenticate", credentials).timingOut(after: self?.timeout ?? 5) { data in
                    print(data)
                }
            }
            unauthenticatedClient.connect()
        } else {
            unauthenticatedClient.emitWithAck("authenticate", credentials).timingOut(after: timeout) { data in
                print(data)
            }
        }
    }

    private func spinUpAuthenticatedClient(with accessToken: String, header: String) -> SocketIOClient {
        var config = configuration
        for option in config {
            if case var .extraHeaders(headers) = option {
                headers[header] = accessToken
                config.insert(.extraHeaders(headers), replacing: true)
                break
            }
        }
        return SocketIOClient(socketURL: baseURL, config: config)
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
