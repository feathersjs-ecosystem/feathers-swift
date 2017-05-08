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

    public init(baseURL: URL, client: SocketIOClient, timeout: Int = 5000) {
        self.baseURL = baseURL
        self.client = client
        self.timeout = timeout
    }

    public func setup() {
        client.connect()
    }

    public func request(endpoint: Endpoint, _ completion: @escaping FeathersCallback) {
        client.emit(endpoint.method.stringMethod, with: [endpoint.parameters ?? [:]])
    }

    public func authenticate(_ path: String, credentials: [String : Any], _ completion: @escaping FeathersCallback) {
        
    }
}
