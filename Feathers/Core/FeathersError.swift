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

public extension FeathersError {
    
    var description: String {
        if let networkError = self as? FeathersNetworkError {
            return networkError.errorMessage
        } else if let serviceError = self as? JuneFeathersError {
            return serviceError.message
        } else {
            return self.localizedDescription
        }
    }
}

public enum JuneFeathersError: FeathersError, Equatable {
    
    case illegal
    
    init() {
        self = .illegal
    }
    
}

extension JuneFeathersError {
    
    var message: String {
        return "Your requests can't be processed at this time"
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

extension FeathersNetworkError {
    
    var errorMessage: String {
        switch self {
        case .badRequest: return "Error #400. Failded to execute your requests."
        case .notAuthenticated: return "Error #401. Not Authenticated. Please Log In."
        case .forbidden: return "Error #403. Failed to execute your request."
        case .notFound: return "Error #404. Failed to execute your request."
        case .methodNotAllowed: return "Error #405. Failed to execute your request."
        case .notAcceptable: return "Error #406. Failed to execute your request."
        case .timeout: return "Error #408. Timed out. Try again later."
        case .conflict: return "Error #409. Failed to execute your requests."
        case .lengthRequired: return "Error #411. Failed to execute your requests."
        case .unprocessable: return "Error #422. Failed to execute your requests."
        case .tooManyRequests: return "Error #429. You made too many requests. Try again later."
        case .general: return "Error #500. Internal Server Error. Try again later."
        case .notImplemented: return "Error #501. Internal Server Error."
        case .badGateway: return "Error #502. Internal Server Error."
        case .unavailable: return "Error #503. Server temporary unavailable. Try again later."
        default: return "Unspecified error occured."
        }
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
