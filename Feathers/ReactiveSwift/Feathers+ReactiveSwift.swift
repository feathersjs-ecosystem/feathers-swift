//
//  Feathers+ReactiveSwift.swift
//  Feathers
//
//  Created by Brendan Conron on 5/5/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import ReactiveSwift
#if !COCOAPODS
    import Feathers
#endif

public extension Reactive where Base: Feathers {

    public func authenticate(_ credentials: [String: Any]) -> SignalProducer<Bool, FeathersError> {
        return SignalProducer { [weak base = base] observer, disposable in
            guard let vBase = base else {
                observer.sendInterrupted()
                return
            }
            vBase.authenticate(credentials) { success, error in
                if let error = error {
                    observer.send(error: error)
                    return
                }
                observer.send(value: success)
                observer.sendCompleted()
            }
        }
    }
    
}
