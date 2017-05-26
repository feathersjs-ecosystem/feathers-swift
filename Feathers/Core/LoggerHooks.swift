//
//  LoggerHooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/15/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import ReactiveSwift

/// Simple request logger
public struct RequestLoggerHook: Hook {

    public func run(with hookObject: HookObject) -> SignalProducer<HookObject, AnyFeathersError> {
        print("request to \(hookObject.service.path) for method \(hookObject.method)")
        return SignalProducer(value: hookObject)
    }

}
