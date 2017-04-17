//
//  AuthenticationOptions.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

public struct AuthenticationOptions {
    let header: String
    let path: String
    let jwtStrategy: String
    let entity: String
    let service: String

    init(
        header: String = "Authorization",
        path: String = "/authentication",
        jwtStrategy: String = "jwt",
        entity: String = "user",
        service: String = "users") {
        self.header = header
        self.path = path
        self.jwtStrategy = jwtStrategy
        self.entity = entity
        self.service = service
    }
}
