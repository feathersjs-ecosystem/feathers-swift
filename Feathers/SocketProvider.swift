//
//  SocketProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import UIKit
import SocketIO
import PromiseKit

public final class SocketProvider: Provider {

    public let baseURL: URL

    private let client: SocketIOClient

    public init(baseURL: URL, client: SocketIOClient) {
        self.baseURL = baseURL
        self.client = client
    }

    public func setup() {
        client.connect()
    }

    public func find(_ path: String, parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            client.emitWithAck("\(path)::find", parameters).timingOut(after: 5000) { data in

            }
        }
    }

    public func get(_ path: String, id: String, parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            client.emitWithAck("\(path)::get", id, parameters).timingOut(after: 5000) { data in

            }
        }
    }

    public func create(_ path: String, data: [String : Any], parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            
        }
    }

    public func update(_ path: String, id: String, data: [String : Any], parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in

        }
    }

    public func patch(_ path: String, id: String, data: [String : Any], parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in

        }
    }

    public func remove(_ path: String, id: String, parameters: [String : Any]) -> Promise<Response> {
        return Promise { fulfill, reject in
            
        }
    }

}
