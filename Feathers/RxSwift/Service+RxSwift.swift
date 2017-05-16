//
//  Service+RxSwift.swift
//  Feathers
//
//  Created by Brendan Conron on 5/7/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import RxSwift

public extension Service {

    public func request(_ method: Service.Method) -> Observable<Response> {
        return Observable.create { [weak self] observer in
            guard let vSelf = self else {
                return Disposables.create()
            }
            vSelf.request(method) { error, response in
                if let error = error {
                    observer.onError(error)
                } else if let response = response {
                    observer.onNext(response)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    public func on(event: Service.RealTimeEvent) -> Observable<[String: Any]> {
        return Observable.create { [weak self] observer in
            guard let vSelf = self else {
                return Disposables.create()
            }
            vSelf.on(event: event) { response in
                observer.onNext(response)
            }
            return Disposables.create {
                vSelf.off(event: event)
            }
        }
    }

    public func once(event: Service.RealTimeEvent) -> Observable<[String: Any]> {
        return Observable.create { [weak self] observer in
            guard let vSelf = self else {
                return Disposables.create()
            }
            vSelf.on(event: event) { response in
                observer.onNext(response)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

}
