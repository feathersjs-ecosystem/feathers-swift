//
//  SocketProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//



#if !os(watchOS)
    import SocketIO
    import Foundation
    import PromiseKit

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

        public func authenticate(_ path: String, credentials: [String : Any], _ completion: @escaping FeathersCallback) {
            client.emitWithAck("authenticate", credentials).timingOut(after: timeout) { data in
                print(data)
            }
        }

        public func find(_ path: String, parameters: [String : Any], _ completion: @escaping FeathersCallback) {
            client.emitWithAck("\(path)::find", parameters).timingOut(after: timeout) { data in
                print(data)
            }
        }

        public func get(_ path: String, id: String, parameters: [String : Any], _ completion: @escaping FeathersCallback) {
            client.emitWithAck("\(path)::get", id, parameters).timingOut(after: 5000) { data in
                print(data)
            }
        }

        public func create(_ path: String, data: [String : Any], parameters: [String : Any], _ completion: @escaping FeathersCallback) {

        }

        public func update(_ path: String, id: String, data: [String : Any], parameters: [String : Any], _ completion: @escaping FeathersCallback) {

        }

        public func patch(_ path: String, id: String, data: [String : Any], parameters: [String : Any], _ completion: @escaping FeathersCallback) {

        }

        public func remove(_ path: String, id: String, parameters: [String : Any], _ completion: @escaping FeathersCallback) {

        }

    }

#endif
