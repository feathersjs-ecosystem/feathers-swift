//
//  SignalProducer+Convenience.swift
//  Feathers
//
//  Created by Brendan Conron on 5/22/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import ReactiveSwift

public extension SignalProducer {

    /// Sends only an interrupted event.
    public static var interrupted: SignalProducer<Value, Error> {
        return SignalProducer { observer, _ in
            observer.sendInterrupted()
        }
    }

}
