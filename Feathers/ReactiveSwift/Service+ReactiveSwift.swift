//
//  Service+ReactiveSwift.swift
//  Feathers
//
//  Created by Brendan Conron on 4/16/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift
#if !COCOAPODS
    import Feathers
#endif

extension Service: ReactiveExtensionsProvider {}

public extension Reactive where Base: Service {

    public func request(_ method: FeathersMethod) -> SignalProducer<Response, FeathersError> {
        return SignalProducer { [weak base = base] observer, disposable in
            guard let vBase = base else {
                observer.sendInterrupted()
                return
            }
            vBase.request(method) { error, response in
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
