//
//  Endpoint.swift
//  Feathers
//
//  Created by Brendan Conron on 5/7/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import Alamofire

public final class Endpoint {

    public let baseURL: URL
    public let path: String
    public let method: Service.Method
    public let accessToken: String?
    public let authenticationConfiguration: AuthenticationConfiguration

    internal init(baseURL: URL, path: String, method: Service.Method, accessToken: String?, authenticationConfiguration: AuthenticationConfiguration) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.accessToken = accessToken
        self.authenticationConfiguration = authenticationConfiguration
    }



}
