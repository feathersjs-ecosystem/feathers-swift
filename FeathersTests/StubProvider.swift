//
//  StubProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Feathers
import Foundation
import PromiseKit

class StubProvider: Provider {

    private let stubbedData: [String: Any]

    var baseURL: URL {
        return URL(string: "http://myserver.com")!
    }

    init(data: [String: Any]) {
        stubbedData = data
    }

    func setup(app: Feathers) {
        // no-op
    }

    func request(endpoint: Endpoint) -> Promise<Response> {
        return Promise(value: Response(pagination: nil, data: .jsonObject(stubbedData)))
    }

    func authenticate(_ path: String, credentials: [String : Any]) -> Promise<Response> {
        return Promise(value: Response(pagination: nil, data: .jsonObject(["accessToken":"some_token"])))
    }

    func logout(path: String) -> Promise<Response> {
        return Promise(value: Response(pagination: nil, data: .jsonObject([:])))
    }

}
