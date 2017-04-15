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

    public final func find(parameters: [AnyHashable: Any]) -> Promise<Any> {
        return provider.find(parameters: parameters)
    }

    public final func get(id: String, parameters: [AnyHashable: Any] = [:]) -> Promise<Any> {
        return provider.get(id: id, parameters: parameters)
    }

    public final func create(data: [AnyHashable: Any], parameters: [AnyHashable: Any] = [:]) -> Promise<Any> {
        return provider.create(data: data, parameters: parameters)
    }

    public final func update(id: String, data: [AnyHashable: Any], parameters: [AnyHashable: Any] = [:]) -> Promise<Any> {
        return provider.update(id: id, data: data, parameters: parameters)
    }

    public final func patch(id: String, data: [AnyHashable: Any], parameters: [AnyHashable: Any] = [:]) -> Promise<Any> {
        return provider.patch(id: id, data: data, parameters: parameters)
    }

    public final func remove(id: String, parameters: [AnyHashable: Any] = [:]) -> Promise<Any> {
        return provider.remove(id: id, parameters: parameters)
    }
    
}
