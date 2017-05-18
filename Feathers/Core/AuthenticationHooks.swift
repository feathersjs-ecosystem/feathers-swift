//
//  AuthenticationHooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/15/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//


/// Hook to reauthenticate the application if it becomes unauthorized
//public struct ReauthenticationHook: Hook {
//
//    public func run(with hookObject: HookObject, _ next: @escaping (HookObject) -> ()) {
//        var object = hookObject
//        let app = object.app
//        // If we're not authenticated, make a call to authenticate before calling next
//        if let error = object.error as? FeathersError, let accessToken = app.authenticationStorage.accessToken, error == .notAuthenticated {
//            app.authenticate([
//                "strategy": app.authenticationConfiguration.jwtStrategy,
//                "accessToken": accessToken
//            ]) { token, error in
//                if let error = error {
//                    object.error = error
//                }
//                next(object)
//            }
//        } else {
//            next(object)
//        }
//    }
//
//}
