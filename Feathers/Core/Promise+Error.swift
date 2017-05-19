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
                }.catch { error in
                    reject(error)
                }
            }
        }
    }

}
