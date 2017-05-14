//
//  Hooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Feathers

struct StubHook: Hook {

    let data: ResponseData

    init(data: ResponseData) {
        self.data = data
    }

    func run(with hookObject: HookObject, _ next: @escaping (HookObject) -> ()) {
        var object = hookObject
        if object.type != .before {
            object.error = NSError(domain: "com.feathersjs.com", code: 0, userInfo: [:])
        } else {
            object.result = Response(pagination: nil, data: data)
        }
        next(object)
    }

}


struct PopuplateDataAfterHook: Hook {

    let data: [String: Any]

    init(data: [String: Any]) {
        self.data = data
    }

    func run(with hookObject: HookObject, _ next: @escaping (HookObject) -> ()) {
        var object = hookObject
        if object.type != .after {
            object.error = NSError(domain: "com.feathersjs.com", code: 0, userInfo: [:])
        } else {
            object.result = Response(pagination: nil, data: .jsonObject(data))
        }
        next(object)
    }

}
