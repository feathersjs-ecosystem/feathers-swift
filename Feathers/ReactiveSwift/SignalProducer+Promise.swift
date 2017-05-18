//
//  SignalProducer+Promise.swift
//  Feathers
//
//  Created by Brendan Conron on 5/18/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit
import ReactiveSwift

extension SignalProducer where SignalProducer.Error: Swift.Error {

    static func from(promise: Promise<Value>) -> SignalProducer<Value, Error> {
        return SignalProducer { (observer: Observer<Value, Error>, disposable: Disposable) in
            promise.then { value -> () in
                observer.send(value: value)
                observer.sendCompleted()
                }.catch { (error: Swift.Error) -> Void in
                    observer.send(error: error as! Error)
            }
        }
    }
    
}
