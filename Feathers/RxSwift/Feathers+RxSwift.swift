//
//  Feathers+RxSwift.swift
//  Feathers
//
//  Created by Brendan Conron on 5/7/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation
import RxSwift
#if !COCOAPODS
    import Feathers
#endif

public extension Feathers {

    public func authenticate(_ credentials: [String: Any]) -> Observable<String> {
        return Observable.create { [weak self] observer in
            guard let vSelf = self else {
                return Disposables.create()
            }
            vSelf.authenticate(credentials) { token, error in
                if let error = error {
                    observer.onError(error)
                    return
                } else if let token = token {
                    observer.onNext(token)
                    observer.onCompleted()
                } else {
                    observer.onError(FeathersError.unknown)
                }
            }
            return Disposables.create()
        }
    }

}
