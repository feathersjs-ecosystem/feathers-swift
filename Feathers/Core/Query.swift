//
//  Query.swift
//  Feathers
//
//  Created by Brendan Conron on 5/25/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

public struct Query {

    public struct Sort {
        let property: String
        let ordering: ComparisonResult
    }

    public enum PropertySubquery {
        case gt(Any)
        case gte(Any)
        case lt(Any)
        case lte(Any)
        case `in`([Any])
        case nin([Any])
        case ne(Any)
        case eq(Any)
    }

    public let limit: Int?
    public let skip: Int?
    public let sorts: [Sort]
    public let propertyQueries: [String: [PropertySubquery]]
    public let selected: [String]
    public let orQuery: [String: PropertySubquery]

    public init() {
        self.limit = nil
        self.skip = nil
        self.sorts = []
        self.propertyQueries = [:]
        self.selected = []
        self.orQuery = [:]
    }

    private init(
        limit: Int? = nil,
        skip: Int? = nil,
        sorts: [Sort] = [],
        propertyQueries: [String: [PropertySubquery]] = [:],
        selected: [String] = [],
        orQuery: [String: PropertySubquery] = [:]) {
        self.limit = limit
        self.skip = skip
        self.sorts = sorts
        self.propertyQueries = propertyQueries
        self.selected = selected
        self.orQuery = orQuery
    }

    public func limit(_ newLimit: Int) -> Query {
        return Query(limit: newLimit, skip: skip, sorts: sorts, propertyQueries: propertyQueries, selected: selected, orQuery: orQuery)
    }

    public func skip(_ newSkip: Int) -> Query {
        return Query(limit: limit, skip: newSkip, sorts: sorts, propertyQueries: propertyQueries, selected: selected, orQuery: orQuery)
    }

    public func gt(property: String, value: Any) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.gt(value))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func gte(property: String, value: Any) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.gte(value))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func lt(property: String, value: Any) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.lt(value))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func lte(property: String, value: Any) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.lte(value))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func `in`(property: String, values: [Any]) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.`in`(values))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func nin(property: String, values: [Any]) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.nin(values))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func eq(property: String, value: Any) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.eq(value))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func ne(property: String, value: Any) -> Query {
        var queries = propertyQueries
        queries[property] = queries[property] == nil ? [] : queries[property]
        queries[property]?.append(.ne(value))
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: queries, selected: selected, orQuery: orQuery)
    }

    public func sort(property: String, ordering: ComparisonResult) -> Query {
        var sortList = sorts
        sortList.append(Sort(property: property, ordering: ordering))
        return Query(limit: limit, skip: skip, sorts: sortList, propertyQueries: propertyQueries, selected: selected, orQuery: orQuery)
    }

    public func select(property: String) -> Query {
        var selectedFields = selected
        selectedFields.append(property)
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: propertyQueries, selected: selectedFields, orQuery: orQuery)
    }

    public func select(properties: [String]) -> Query {
        var selectedFields = selected
        selectedFields += properties
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: propertyQueries, selected: selectedFields, orQuery: orQuery)
    }

    public func or(subqueries: [String: PropertySubquery]) -> Query {
        return Query(limit: limit, skip: skip, sorts: sorts, propertyQueries: propertyQueries, selected: selected, orQuery: subqueries)
    }

    public func serialize() -> [String: Any] {
        return QuerySerializer.serialize(limit: limit, skip: skip, sorts: sorts, propertyQueries: propertyQueries, selected: selected, orQuery: orQuery)
    }
}
