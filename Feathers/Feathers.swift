//
//  Feathers.swift
//  Feathers
//
//  Created by Brendan Conron on 4/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

public final class Feathers {

    public let provider: Provider

    init(provider: Provider) {
        self.provider = provider
    }

    func service(path: String) -> Service {
        return Service(provider: provider, path: path)
    }

}
