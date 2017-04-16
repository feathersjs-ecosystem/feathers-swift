//
//  Response.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import Alamofire

struct Pagination {
    let total: Int
    let limit: Int
    let skip: Int
}

public enum ResponseData: CustomDebugStringConvertible, CustomStringConvertible {
    case jsonArray([Any])
    case jsonObject(Any)

    public var description: String {
        switch self {
        case .jsonArray(let data):
            return data.reduce("") { $0 + "\($1)\n" }
        case .jsonObject(let object):
            return "\(object)"
        }
    }

    public var debugDescription: String {
        return description
    }
}

public struct Response: CustomDebugStringConvertible, CustomStringConvertible {

    let pagination: Pagination?
    let data: ResponseData

    public var description: String {
        guard let page = pagination else {
            return "Data: \(data)"
        }
        return "Total: \(page.total)\nLimit: \(page.limit),Skip: \(page.skip)\nData: \(data)"

    }

    public var debugDescription: String {
        return description
    }

}
