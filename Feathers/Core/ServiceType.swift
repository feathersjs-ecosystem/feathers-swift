//
//  ServiceType.swift
//  Feathers
//
//  Created by Brendan Conron on 5/21/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public protocol ServiceType {

    var path: String { get }

    func setup(app: Feathers, path: String)
    
    func request(_ method: Service.Method) -> SignalProducer<Response, FeathersError>

    /// Register hooks with the service.
    /// Hooks get added with each successive use, not overridden.
    ///
    /// - Parameters:
    ///   - before: Before hooks.
    ///   - after: After hooks.
    ///   - error: Error hooks.
    func hooks(before: Service.Hooks?, after: Service.Hooks?, error: Service.Hooks?)

    func hooks(for kind: HookObject.Kind) -> Service.Hooks?

    func on(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError>

    func once(event: Service.RealTimeEvent) -> Signal<[String: Any], NoError>
    func off(event: Service.RealTimeEvent)
    
}
