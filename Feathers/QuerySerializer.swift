//
//  QuerySerializer.swift
//  Feathers-iOS
//
//  Created by Ostap Holub on 3/25/19.
//  Copyright © 2019 Swoopy Studios. All rights reserved.
//

import Foundation

public class QuerySerializer {
    
    public class func serialize(limit: Int?, skip: Int?, sorts: [Query.Sort], propertyQueries: [String: [Query.PropertySubquery]], selected: [String], orQuery: [String: Query.PropertySubquery]) -> [String: Any] {
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
