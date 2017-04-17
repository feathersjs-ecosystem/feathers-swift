//
//  Feathers.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift
import PromiseKit

public final class Feathers {

    public let provider: Provider
    public let baseURL: URL

    fileprivate var authOptions: AuthenticationOptions?

    public init(baseURL: URL, provider: Provider) {
        self.provider = provider
        self.baseURL = baseURL
    }

    public func service(path: String) -> Service {
        return Service(provider: provider, path: path)
    }

    public func configure(auth options: AuthenticationOptions) {
        authOptions = options
    }

    public func authenticate(_ credentials: [String: Any]) -> Promise<Response> {
        return provider.authenticate(authOptions?.path ?? "/authentication", credentials: credentials)
    }

}

extension Reactive where Base: Feathers {

    public func authenticate(_ credentials: [String: Any]) -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.authenticate(credentials))
    }

}
