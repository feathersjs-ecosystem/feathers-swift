//
//  Hooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/13/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

/// Hook object that gets passed through hook functions
public struct HookObject {

    /// Represents the kind of hook.
    ///
    /// - before: Hook is run before the request is made.
    /// - after: Hook is run after the request is made.
    /// - error: Runs when there's an error.
    public enum Kind {
        case before, after, error(Error)
    }

    /// The kind of hook.
    let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

}

/// Hook function 
public typealias HookFunction = (HookObject, (HookObject) -> ()) -> ()
