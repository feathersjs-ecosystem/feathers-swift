//
//  Response.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import Alamofire

/// Describes a request's pagination properties.
public struct Pagination {
    let total: Int
    let limit: Int
    let skip: Int
}

/// Encapsulation around the kinds of response data we can receive.
///
/// - jsonArray: Data is a JSON array (non-paginated).
/// - jsonObject: Data is a JSON object (paginated or single entity request i.e. `get`, `update`, `patch`, or `remove`.
public enum ResponseData: CustomDebugStringConvertible, CustomStringConvertible, Equatable {
    case jsonArray([Any])
    case jsonObject(Any)

    public var value: Any {
        switch self {
        case .jsonObject(let data): return data
        case .jsonArray(let data): return data
        }
    }

    public var description: String {
        switch self {
        case .jsonArray(let data):
            return data.reduce("") { $0 + "\n\($1)\n" }
        case .jsonObject(let object):
            return "\(object)"
        }
    }

    public var debugDescription: String {
        return description
    }
}

// Only to be used for testing, does not actually compare equality of the json data
public func ==(lhs: ResponseData, rhs: ResponseData) -> Bool {
    if case  .jsonObject = lhs, case .jsonObject = rhs {
        return true
    } else if case .jsonArray = lhs, case .jsonArray = rhs {
        return true
    }
    return false
}

/// Encapsulates a successful response from the service.
public struct Response: CustomDebugStringConvertible, CustomStringConvertible {

    /// Pagination information.
    public let pagination: Pagination?

    /// The response data.
    public let data: ResponseData

    public var description: String {
        guard let page = pagination else {
            return "Data: \(data)"
        }
        return "Total: \(page.total)\nLimit: \(page.limit),Skip: \(page.skip)\nData: \(data)"

    }

    public init(pagination: Pagination?, data: ResponseData) {
        self.pagination = pagination
        self.data = data
    }

    public var debugDescription: String {
        return description
    }

}
