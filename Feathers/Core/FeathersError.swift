//
//  FeathersError.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation

public struct FeathersError: Error {
    
    public let payload: [String: Any]
    public let statusCode: Int
    public let description: String
    
    init(payload: [String: Any], statusCode: Int) {
        self.payload = payload
        self.statusCode = statusCode
        self.description = "parsed description from payload"
    }
    
    init(reason: String) {
        self.description = reason
        self.payload = [:]
        self.statusCode = -1
    }
    
    init(error: Error) {
        self.description = error.localizedDescription
        self.payload = [:]
        self.statusCode = -1
    }
}
