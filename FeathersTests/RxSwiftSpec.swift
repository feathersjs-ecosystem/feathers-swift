//
//  RxSwiftSpec.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Quick
import Nimble
import Feathers
import RxSwift
import PromiseKit

class RxSwiftSpec: QuickSpec {

    override func spec() {

        describe("RxSwift Extensions") {

            var app: Feathers!
            var service: Service!

            beforeEach {
                app = Feathers(provider: StubProvider(data: ["name": "bob"]))
                service = app.service(path: "users")
            }

            describe("Feathers") {

                it("should authenticate successfully") {
                    var receivedNext = false
                    var receivedError = false
                    var didComplete = false
                    var didDispose = false
                    let _ = app.authenticate([:])
                        .do(onNext: { _ in
                            receivedNext = true
                        }, onError: { _ in
                            receivedError = true
                        }, onCompleted: {
                            didComplete = true
                        }, onDispose: {
                            didDispose = true
                        })
                        .subscribe()
                    expect(receivedNext).toEventually(beTrue())
                    expect(receivedError).toEventually(beFalse())
                    expect(didComplete).toEventually(beTrue())
                    expect(didDispose).toEventually(beTrue())
                }

                it("should logout successfully") {
                    var receivedNext = false
                    var receivedError = false
                    var didComplete = false
                    var didDispose = false
                    let _ = app.logout()
                        .do(onNext: { _ in
                            receivedNext = true
                        }, onError: { _ in
                            receivedError = true
                        }, onCompleted: {
                            didComplete = true
                        }, onDispose: {
                            didDispose = true
                        })
                        .subscribe()
                    expect(receivedNext).toEventually(beTrue())
                    expect(receivedError).toEventually(beFalse())
                    expect(didComplete).toEventually(beTrue())
                    expect(didDispose).toEventually(beTrue())
                }

            }

            describe("Service") {

                it("should make a request successfully") {
                    var receivedNext = false
                    var receivedError = false
                    var didComplete = false
                    var didDispose = false
                    let _ = service.request(.find(parameters: nil))
                        .do(onNext: { _ in
                            receivedNext = true
                        }, onError: { _ in
                            receivedError = true
                        }, onCompleted: {
                            didComplete = true
                        }, onDispose: {
                            didDispose = true
                        })
                        .subscribe()
                    expect(receivedNext).toEventually(beTrue())
                    expect(receivedError).toEventually(beFalse())
                    expect(didComplete).toEventually(beTrue())
                    expect(didDispose).toEventually(beTrue())
                }

            }

            describe("Promises") {

                it("should forward the promises value") {
                    var value = 0
                    let _ = Observable<Int>.from(promise: Promise(value: 1))
                        .do(onNext: {
                            value = $0
                        })
                        .subscribe()
                    expect(value).toEventually(equal(1))
                }
            }
            
        }
        
    }
    
}
