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

    public func authenticate(_ credentials: [String: Any]) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let vSelf = self else {
                return Disposables.create()
            }
            vSelf.authenticate(credentials) { success, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                observer.onNext(success)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

}
