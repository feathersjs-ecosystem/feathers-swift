//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

public enum FeathersMethod {
    case find(parameters: [String: Any]?)
    case get(id: String, parameters: [String: Any]?)
    case create(data: [String: Any], parameters: [String: Any]?)
    case update(id: String, data: [String: Any], parameters: [String: Any]?)
    case patch(id: String, data: [String: Any], paramters: [String: Any]?)
    case remove(id: String, parameters: [String: Any]?)
}

final public class Service {

    public let provider: Provider
    public let path: String

    internal init(provider: Provider, path: String) {
        self.provider = provider
        self.path = path
    }

    public func request(_ method: FeathersMethod, _ completion: @escaping FeathersCallback) {
        provider.request(path: path, method: method, completion)
    }

}
