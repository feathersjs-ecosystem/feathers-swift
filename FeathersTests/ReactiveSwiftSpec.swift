//
//  ReactiveSwiftSpec.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Quick
import Nimble
import ReactiveSwift
import Feathers

class ReactiveSwift: QuickSpec {

    override func spec() {

        describe("ReactiveSwift Extensions") {

            var app: Feathers!
            var service: Service!

            beforeEach {
                app = Feathers(provider: StubProvider())
                service = app.service(path: "users")
            }

            describe("Feathers") {

                it("should authenticte successfully") {
                    var didDispose = false
                    var didReceiveValue = false
                    var didComplete = false
                    var didInterrupt = false
                    app.reactive.authenticate([:]).on(completed: {
                        didComplete = true
                    }, interrupted: {
                        didInterrupt = true
                    }, disposed: {
                        didDispose = true
                    }, value: { value in
                        didReceiveValue = true
                    })
                    .start()
                    expect(didDispose).toEventually(beTrue())
                    expect(didInterrupt).toEventually(beFalse())
                    expect(didReceiveValue).toEventually(beTrue())
                    expect(didComplete).toEventually(beTrue())

                }

                it("should logout successfully") {
                    var didDispose = false
                    var didReceiveValue = false
                    var didComplete = false
                    var didInterrupt = false
                    app.reactive.logout().on(completed: {
                        didComplete = true
                    }, interrupted: {
                        didInterrupt = true
                    }, disposed: {
                        didDispose = true
                    }, value: { value in
                        didReceiveValue = true
                    })
                        .start()
                    expect(didDispose).toEventually(beTrue())
                    expect(didInterrupt).toEventually(beFalse())
                    expect(didReceiveValue).toEventually(beTrue())
                    expect(didComplete).toEventually(beTrue())
                }

            }

            describe("Service") {

                it("should send a request") {
                    var didDispose = false
                    var didReceiveValue = false
                    var didComplete = false
                    var didInterrupt = false
                    service.reactive.request(.find(parameters: nil))
                        .on(completed: {
                            didComplete = true
                        }, interrupted: {
                            didInterrupt = true
                        }, disposed: {
                            didDispose = true
                        }, value: { value in
                            didReceiveValue = true
                        })
                        .start()

                    expect(didDispose).toEventually(beTrue())
                    expect(didInterrupt).toEventually(beFalse())
                    expect(didReceiveValue).toEventually(beTrue())
                    expect(didComplete).toEventually(beTrue())
                }

            }

        }

    }

}
