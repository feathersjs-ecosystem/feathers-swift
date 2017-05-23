//
//  Hooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Feathers
import Foundation
import ReactiveSwift
import Result

/// Hook that always errors
struct ErrorHook: Hook {

    let error: FeathersError

    init(error: FeathersError) {
        self.error = error
    }

    func run(with hookObject: HookObject) -> SignalProducer<HookObject, FeathersError> {
        return SignalProducer(error: error)
    }

}

// Hook that doesn't reject, just modifies the error
struct ModifyErrorHook: Hook {
    let error: FeathersError

    init(error: FeathersError) {
        self.error = error
    }

    func run(with hookObject: HookObject) -> SignalProducer<HookObject, FeathersError> {
        var object = hookObject
        object.error = error
        return SignalProducer(value: object)
    }

}

struct StubHook: Hook {

    let data: ResponseData

    init(data: ResponseData) {
        self.data = data
    }

    func run(with hookObject: HookObject) -> SignalProducer<HookObject, FeathersError> {
        var object = hookObject
        object.result = Response(pagination: nil, data: data)
        return SignalProducer(value: object)
    }

}


struct PopuplateDataAfterHook: Hook {

    let data: [String: Any]

    init(data: [String: Any]) {
        self.data = data
    }

    func run(with hookObject: HookObject) -> SignalProducer<HookObject, FeathersError> {
        var object = hookObject
        object.result = Response(pagination: nil, data: .jsonObject(data))
        return SignalProducer(value: object)
    }

}
