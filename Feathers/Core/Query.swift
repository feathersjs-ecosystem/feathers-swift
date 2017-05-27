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
        var dictionary: [String: Any] = [:]
        // Add any limit
        if let limit = limit {
            dictionary["$limit"] = limit
        }
        // Add any skip
        if let skip = skip {
            dictionary["$skip"] = skip
        }
        // Seralize sorts
        for sort in sorts {
            var previousSorts = dictionary["$sort"] as? [String: Int] ?? [:]
            switch sort.ordering {
            case .orderedAscending:
                previousSorts[sort.property] = 1
            case .orderedDescending:
                previousSorts[sort.property] = -1
            case .orderedSame:
                previousSorts[sort.property] = 0
            }
            dictionary["$sort"] = previousSorts
        }
        for (property, subqueries) in propertyQueries {
            var propertyQueries = dictionary[property] as? [String: Any] ?? [:]
            var isSubquery = true
            for subquery in subqueries {
                switch subquery {
                case let .gt(value):
                    propertyQueries["$gt"] = value
                case let .gte(value):
                    propertyQueries["$gte"] = value
                case let .lt(value):
                    propertyQueries["$lt"] = value
                case let .lte(value):
                    propertyQueries["$lte"] = value
                case let .`in`(values):
                    propertyQueries["$in"] = values
                case let .nin(values):
                    propertyQueries["$nin"] = values
                case let .ne(value):
                    propertyQueries["$ne"] = value
                case let .eq(value):
                    dictionary[property] = value
                    isSubquery = false
                }
            }
            if isSubquery {
                dictionary[property] = propertyQueries
            }
        }

        if !selected.isEmpty {
            dictionary["$select"] = selected
        }

        var orQueries: [[String: Any]] = []
        for (property, subquery) in orQuery {
            var propertyQuery: [String: Any] = [:]
            switch subquery {
            case let .gt(value):
                propertyQuery[property] = ["$gt": value]
            case let .gte(value):
                propertyQuery[property] = ["$gte": value]
            case let .lt(value):
                propertyQuery[property] = ["$lt": value]
            case let .lte(value):
                propertyQuery[property] = ["$lte": value]
            case let .`in`(values):
                propertyQuery[property] = ["$in": values]
            case let .nin(values):
                propertyQuery[property] = ["$nin": values]
            case let .ne(value):
                propertyQuery[property] = ["$ne": value]
            case let .eq(value):
                propertyQuery[property] = value
            }
            orQueries.append(propertyQuery)
        }

        if !orQueries.isEmpty {
            dictionary["$or"] = orQueries
        }

        return dictionary
    }

}
