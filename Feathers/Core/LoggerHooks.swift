//
//  LoggerHooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit

/// Simple request logger
public struct RequestLoggerHook: Hook {

    public func run(with hookObject: HookObject) -> Promise<HookObject> {
        print("request to \(hookObject.service.path) for method \(hookObject.method)")
        return Promise(value: hookObject)
    }

}
