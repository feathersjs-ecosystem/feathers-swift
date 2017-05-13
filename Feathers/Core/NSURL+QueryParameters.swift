//
//  NSURL+QueryParameters.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

internal extension URL {

    /// Create a url by appending query parameters.
    ///
    /// - Parameter parameters: Query parameters.
    /// - Returns: New url with query parameters appended to the end.
    internal func URLByAppendingQueryParameters(parameters: [String: Any]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        urlComponents.queryItems = urlComponents.queryItems ?? [] + parameters.map { URLQueryItem(name: $0, value: "\($1)") }
        return urlComponents.url
    }

}
