//
//  FeathersError.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

enum FeathersError: Error {

    case badRequest
    case notAuthenticated
    case paymentError
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case timeout
    case conflict
    case lengthRequired
    case unprocessable
    case tooManyRequests
    case general
    case notImplemented
    case badGateway
    case unavailable
    case underlying(Error)
    case unknown

    init?(statusCode: Int) {
        switch statusCode {
            case 400: self = .badRequest
            case 401: self = .notAuthenticated
            case 403: self = .forbidden
            case 404: self = .notFound
            case 405: self = .methodNotAllowed
            case 406: self = .notAcceptable
            case 408: self = .timeout
            case 409: self = .conflict
            case 411: self = .lengthRequired
            case 422: self = .unprocessable
            case 429: self = .tooManyRequests
            case 500: self = .general
            case 501: self = .notImplemented
            case 502: self = .badGateway
            case 503: self = .unavailable
            default: return nil
        }
    }

    init(error: Error) {
        self = .underlying(error)
    }
    
}
