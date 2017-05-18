//
//  Promise+Error.swift
//  Feathers
//
//  Created by Brendan Conron on 5/18/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import PromiseKit

public extension Promise {

    func flatMapError<U>(_ transform: @escaping (Error) -> Promise<U>) -> Promise<U> {
        return Promise<U> { [weak self] resolve, reject in
            self?.catch { error in
                let promise = transform(error)
                let _ = promise.then { value in
                    resolve(value)
                }
            }
        }
    }



//    public func flatMapError<F>(_ transform: @escaping (Error) -> SignalProducer<Value, F>) -> Signal<Value, F> {
//        return Signal<Value, F> { observer in
//            self.observeFlatMapError(transform, observer, SerialDisposable())
//        }
//    }

//    fileprivate func observeFlatMapError<F>(_ handler: @escaping (Error) -> SignalProducer<Value, F>, _ observer: Signal<Value, F>.Observer, _ serialDisposable: SerialDisposable) -> Disposable? {
//        return self.observe { event in
//            switch event {
//            case let .value(value):
//                observer.send(value: value)
//            case let .failed(error):
//                handler(error).startWithSignal { signal, disposable in
//                    serialDisposable.inner = disposable
//                    signal.observe(observer)
//                }
//            case .completed:
//                observer.sendCompleted()
//            case .interrupted:
//                observer.sendInterrupted()
//            }
//        }
//    }

}
