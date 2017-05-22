//
//  FeathersSpec.swift
//  Feathers
//
//  Created by Brendan Conron on 5/20/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Quick
import Nimble
import ReactiveSwift
import Feathers

class FeathersSpec: QuickSpec {
    override func spec() {

        describe("ReactiveSwift Extensions") {

            describe("Feathers") {

                var app: Feathers!

                beforeEach {
                    app = Feathers(provider: StubProvider(data: ["name": "Bob"]))
                }

                it("should authenticte successfully") {
                    var didDispose = false
                    var didReceiveValue = false
                    var didComplete = false
                    var didInterrupt = false
                    app.authenticate([:]).on(completed: {
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
                    app.logout().on(completed: {
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
