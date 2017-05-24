//
//  StubProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Feathers
import Foundation
import ReactiveSwift
import enum Result.NoError

class StubProvider: Provider {

    private let stubbedData: [String: Any]

    var supportsRealtimeEvents: Bool {
        return false
    }

    var baseURL: URL {
        return URL(string: "https://myserver.com")!
    }

    init(data: [String: Any]) {
        stubbedData = data
    }

    func setup(app: Feathers) {
        // no-op
    }

    func request(endpoint: Endpoint) -> SignalProducer<Response, FeathersError> {
        return SignalProducer(value: Response(pagination: nil, data: .jsonObject(stubbedData)))
    }

    func authenticate(_ path: String, credentials: [String : Any]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer(value: Response(pagination: nil, data: .jsonObject(["accessToken":"some_token"])))
    }

    func logout(path: String) -> SignalProducer<Response, FeathersError> {
        return SignalProducer(value: Response(pagination: nil, data: .jsonObject([:])))
    }

    public func on(event: String) -> Signal<[String: Any], NoError> {
        // no-op
        return .empty
    }

    public func once(event: String) -> Signal<[String: Any], NoError> {
        return .empty
    }

    public func off(event: String) {
        // no-op
    }

    

}
