//
//  Feathers+RxSwift.swift
//  Feathers
//
//  Created by Brendan Conron on 5/7/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import RxSwift

public extension Feathers {

    public func authenticate(_ credentials: [String: Any]) -> Observable<String> {
        return Observable.from(promise: authenticate(credentials))
    }

    public func logout() -> Observable<Response> {
        return Observable.from(promise: logout())
    }

}
