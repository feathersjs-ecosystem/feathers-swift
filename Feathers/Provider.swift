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

    init(baseURL: URL)

    func find(_ path: String, parameters: [String: Any]) -> Promise<Response>

    func get(_ path: String, id: String, parameters: [String: Any]) -> Promise<Response>

    func create(_ path: String, data: [String: Any], parameters: [String: Any]) -> Promise<Response>

    func update(_ path: String, id: String, data: [String: Any], parameters: [String: Any]) -> Promise<Response>

    func patch(_ path: String, id: String, data: [String: Any], parameters: [String: Any]) -> Promise<Response>

    func remove(_ path: String, id: String, parameters: [String: Any]) -> Promise<Response>

}
