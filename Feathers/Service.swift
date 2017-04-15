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

    public final func find(parameters: [AnyHashable: Any]) {

    }

    public final func get(id: String, parameters: [AnyHashable: Any] = [:]) {

    }

    public final func create(data: [AnyHashable: Any], parameters: [AnyHashable: Any] = [:]) {

    }

    public final func update(id: String, data: [AnyHashable: Any], parameters: [AnyHashable: Any] = [:]) {

    }

    public final func patch(id: String, data: [AnyHashable: Any], parameters: [AnyHashable: Any] = [:]) {

    }

    public final func remove(id: String, parameters: [AnyHashable: Any] = [:]) {

    }
    
}
