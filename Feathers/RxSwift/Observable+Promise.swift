//
//  Observable+Promise.swift
//  Feathers
//
//  Created by Brendan Conron on 5/18/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import RxSwift
import PromiseKit

public extension Observable {

    static public func from(promise: Promise<Element>) -> Observable<Element> {
        return Observable.create { observer in
            promise.then { value -> () in
                observer.onNext(value)
                observer.onCompleted()
            }.catch { (error: Error) -> Void in
                observer.onError(error)
            }
            return Disposables.create()

        }
    }

}
