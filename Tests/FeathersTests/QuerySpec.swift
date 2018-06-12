//
//  QuerySpec.swift
//  Feathers
//
//  Created by Brendan Conron on 5/25/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Quick
import Nimble
import Foundation
import Feathers

class QuerySpec: QuickSpec {

    override func spec() {

        describe("Query") {

            it("should serialize a limit query") {
                let query = Query().limit(5)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: ["$limit": 5])).to(beTrue())
            }

            it("should serialize a skip query") {
                let query = Query().skip(5)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: ["$skip": 5])).to(beTrue())
            }

            it("should serialize a single sort") {
                let query = Query().sort(property: "name", ordering: .orderedAscending)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "$sort": [
                        "name": 1
                    ]
                ])).to(beTrue())
            }

            it("should serialize a multiple sorts") {
                let query = Query().sort(property: "name", ordering: .orderedAscending).sort(property: "age", ordering: .orderedDescending)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "$sort": [
                        "name": 1,
                        "age": -1
                    ]
                    ])).to(beTrue())
            }

            it("should serialize a gt query") {
                let query = Query().gt(property: "age", value: 5)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$gt": 5
                    ]
                    ])).to(beTrue())
            }

            it("should serialize a gte query") {
                let query = Query().gte(property: "age", value: 5)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$gte": 5
                    ]
                    ])).to(beTrue())
            }

            it("should serialize a lt query") {
                let query = Query().lt(property: "age", value: 5)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$lt": 5
                    ]
                    ])).to(beTrue())
            }

            it("should serialize a lte query") {
                let query = Query().lte(property: "age", value: 5)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$lte": 5
                    ]
                    ])).to(beTrue())
            }

            it("should serialize an in query") {
                let query = Query().in(property: "age", values: [5, 10, 15])
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$in": [5, 10, 15]
                    ]
                    ])).to(beTrue())
            }

            it("should serialize a nin query") {
                let query = Query().nin(property: "age", values: [5, 10, 15])
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$nin": [5, 10, 15]
                    ]
                    ])).to(beTrue())
            }

            it("should serialize a ne query") {
                let query = Query().ne(property: "age", value: 10)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$ne": 10
                    ]
                    ])).to(beTrue())
            }

            it("should serialize an eq query") {
                let query = Query().eq(property: "age", value: 10)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": 10
                    ])).to(beTrue())
            }

            it("should serialize a select query") {
                let query = Query().select(property: "name")
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "$select": ["name"]
                    ])).to(beTrue())
            }

            it("should serialize a select query with multiple fields") {
                let query = Query().select(properties: ["name", "age"])
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "$select": ["name", "age"]
                ])).to(beTrue())
            }

            it("should serialize an or query") {
                let query = Query().or(subqueries: [
                    "name":.ne("bob"),
                    "age": .`in`([18, 42])
                    ])
                let serialized = query.serialize()
                print(serialized)
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "$or": [
                        [
                            "name": [
                                "$ne": "bob"
                            ]
                        ],
                        [
                            "age": [
                                "$in": [18, 42]
                            ]
                        ]
                    ]
                    ])).to(beTrue())
            }

            it("should serialize multiple queries") {
                let query = Query().limit(5).gt(property: "name", value: "bob").lt(property: "age", value: 5)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "$limit": 5,
                    "name": [
                        "$gt": "bob"
                    ],
                    "age": [
                        "$lt": 5
                    ]
                    ])).to(beTrue())
            }

            it("should serialize multiple subqueries on the same property") {
                let query = Query().gt(property: "age", value: 18).lt(property: "age", value: 100)
                let serialized = query.serialize()
                expect(NSDictionary(dictionary: serialized).isEqual(to: [
                    "age": [
                        "$gt": 18,
                        "$lt": 100
                    ]
                    ])).to(beTrue())
            }


        }

    }

}
