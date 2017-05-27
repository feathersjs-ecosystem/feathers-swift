//
//  Response.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation

/// Describes a request's pagination properties.
public struct Pagination {
    let total: Int
    let limit: Int
    let skip: Int

    public init(total: Int, limit: Int, skip: Int) {
        self.total = total
        self.limit = limit
        self.skip = skip
    }
}

/// Encapsulation around the kinds of response data we can receive.
///
/// - list: Data is in list format (non-paginated).
/// - object: Data is a JSON object (paginated or single entity request i.e. `get`, `update`, `patch`, or `remove`.
public enum ResponseData: CustomDebugStringConvertible, CustomStringConvertible, Equatable {
    case list([Any])
    case object(Any)

    public var value: Any {
        switch self {
        case .object(let data): return data
        case .list(let data): return data
        }
    }

    public var description: String {
        switch self {
        case .list(let data):
            return data.reduce("") { $0 + "\n\($1)\n" }
        case .object(let object):
            return "\(object)"
        }
    }

    public var debugDescription: String {
        return description
    }
}

// Only to be used for testing, does not actually compare equality of the json data
public func == (lhs: ResponseData, rhs: ResponseData) -> Bool {
    if case  .object = lhs, case .object = rhs {
        return true
    } else if case .list = lhs, case .list = rhs {
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
