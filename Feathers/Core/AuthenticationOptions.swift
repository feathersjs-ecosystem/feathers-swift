//
//  AuthenticationOptions.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

public struct AuthenticationOptions {

    /// Authorization header field in requests.
    let header: String

    /// Path for authentication service.
    let path: String

    /// Strategy name for jwt authentication.
    let jwtStrategy: String

    /// The entity you are authenticating.
    let entity: String

    /// The service to look up the entity
    let service: String

    /// The name of the cookie to parse the JWT from when cookies are enabled server side.
    let cookie: String

    // The key to store the accessToken with.
    let storageKey: String

    /// Storage object that automatically stores the accessToken.
    /// Use the default. It's encrypted. Use it.
    let storage: AuthenticationStorage

    init(
        header: String = "Authorization",
        path: String = "/authentication",
        jwtStrategy: String = "jwt",
        entity: String = "user",
        service: String = "users",
        cookie: String = "feathers-jwt",
        storageKey: String = "feathers-jwt",
        storage: AuthenticationStorage = EncryptedAuthenticationStore(storageKey: "feathers-jwt")) {
        self.header = header
        self.path = path
        self.jwtStrategy = jwtStrategy
        self.entity = entity
        self.service = service
        self.cookie = cookie
        self.storageKey = storageKey
        self.storage = storage
    }
}
