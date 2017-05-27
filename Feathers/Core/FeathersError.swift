//
//  FeathersError.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation

public protocol FeathersError: Swift.Error {}

/// Type erase any errors
public struct AnyFeathersError: Error {
    /// The underlying error.
    public let error: FeathersError

    public init(_ error: FeathersError) {
        if let anyError = error as? AnyFeathersError {
            self = anyError
        } else {
            self.error = error
        }
    }
}

public enum FeathersNetworkError: FeathersError, Equatable {

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

    public init?(statusCode: Int) {
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

    public init(error: Error) {
        self = .underlying(error)
    }
    
}

public func == (lhs: FeathersNetworkError, rhs: FeathersNetworkError) -> Bool {
    switch (lhs, rhs) {
    case (.badRequest, .badRequest): return true
    case (.notAuthenticated, .notAuthenticated): return true
    case (.paymentError, .paymentError): return true
    case (.forbidden, .forbidden): return true
    case (.notFound, .notFound): return true
    case (.methodNotAllowed, .methodNotAllowed): return true
    case (.notAcceptable, .notAcceptable): return true
    case (.timeout, .timeout): return true
    case (.conflict, .conflict): return true
    case (.lengthRequired, .lengthRequired): return true
    case (.unprocessable, .unprocessable): return true
    case (.tooManyRequests, .tooManyRequests): return true
    case (.general, .general): return true
    case (.notImplemented, .notImplemented): return true
    case (.badGateway, .badGateway): return true
    case (.unavailable, .unavailable): return true
    case (.underlying(_), .underlying(_)): return true
    case (.unknown, .unknown): return true
    default: return false
    }
}
