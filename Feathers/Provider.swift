//
//  Provider.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Provider {

    init()

    func find(parameters: [AnyHashable: Any]) -> Promise<Any>

    func get(id: String, parameters: [AnyHashable: Any]) -> Promise<Any>

    func create(data: [AnyHashable: Any], parameters: [AnyHashable: Any]) -> Promise<Any>

    func update(id: String, data: [AnyHashable: Any], parameters: [AnyHashable: Any]) -> Promise<Any>

    func patch(id: String, data: [AnyHashable: Any], parameters: [AnyHashable: Any]) -> Promise<Any>

    func remove(id: String, parameters: [AnyHashable: Any]) -> Promise<Any>

}
