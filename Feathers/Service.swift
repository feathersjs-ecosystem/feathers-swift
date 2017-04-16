//
//  Service.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit

final public class Service {

    public let provider: Provider
    public let path: String

    internal init(provider: Provider, path: String) {
        self.provider = provider
        self.path = path
    }

    public final func find(parameters: [String: Any]) -> Promise<Response> {
        return provider.find(path, parameters: parameters)
    }

    public final func get(id: String, parameters: [String: Any] = [:]) -> Promise<Response> {
        return provider.get(path, id: id, parameters: parameters)
    }

    public final func create(data: [String: Any], parameters: [String: Any] = [:]) -> Promise<Response> {
        return provider.create(path, data: data, parameters: parameters)
    }

    public final func update(id: String, data: [String: Any], parameters: [String: Any] = [:]) -> Promise<Response> {
        return provider.update(path, id: id, data: data, parameters: parameters)
    }

    public final func patch(id: String, data: [String: Any], parameters: [String: Any] = [:]) -> Promise<Response> {
        return provider.patch(path, id: id, data: data, parameters: parameters)
    }

    public final func remove(id: String, parameters: [String: Any] = [:]) -> Promise<Response> {
        return provider.remove(path, id: id, parameters: parameters)
    }
    
}
