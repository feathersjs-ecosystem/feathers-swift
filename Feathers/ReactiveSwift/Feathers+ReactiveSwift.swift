//
//  Feathers+ReactiveSwift.swift
//  Feathers
//
//  Created by Brendan Conron on 5/5/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift

extension Feathers: ReactiveExtensionsProvider {}

public extension Reactive where Base: Feathers {

    public func authenticate(_ credentials: [String: Any]) -> SignalProducer<String, FeathersError> {
        return SignalProducer.from(promise: base.authenticate(credentials))
    }

    public func logout() -> SignalProducer<Response, FeathersError> {
        return SignalProducer.from(promise: base.logout())
    }

}
