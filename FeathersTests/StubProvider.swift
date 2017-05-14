//
//  StubProvider.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Feathers

class StubProvider: Provider {

    var baseURL: URL {
        return URL(string: "http://myserver.com")!
    }

    func setup(app: Feathers) {
        // no-op
    }

    func request(endpoint: Endpoint, _ completion: @escaping FeathersCallback) {
        completion(nil, Response(pagination: nil, data: .jsonObject([:])))
    }

    func authenticate(_ path: String, credentials: [String : Any], _ completion: @escaping FeathersCallback) {
        completion(nil, Response(pagination: nil, data: .jsonObject([:])))
    }

    func logout(path: String, _ completion: @escaping FeathersCallback) {
        completion(nil, Response(pagination: nil, data: .jsonObject([:])))
    }

}
