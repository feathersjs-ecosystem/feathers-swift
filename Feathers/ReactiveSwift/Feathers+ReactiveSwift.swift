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
        return SignalProducer { [weak base = base] observer, disposable in
            guard let vBase = base else {
                observer.sendInterrupted()
                return
            }
            vBase.authenticate(credentials) { token, error in
                if let error = error {
                    observer.send(error: error)
                } else if let token = token {
                    observer.send(value: token)
                    observer.sendCompleted()
                } else {
                    observer.send(error: .unknown)
                }
            }
        }
    }

    public func logout() -> SignalProducer<Response, FeathersError> {
        return SignalProducer { [weak base = base] observer, disposable in
            guard let vBase = base else {
                observer.sendInterrupted()
                return
            }
            vBase.logout { error, response in
                if let error = error {
                    observer.send(error: error)
                } else if let response = response {
                    observer.send(value: response)
                    observer.sendCompleted()
                } else {
                    observer.send(error: .unknown)
                }
            }
        }
    }
    
}
