//
//  ServiceSpec.swift
//  Feathers
//
//  Created by Brendan Conron on 5/18/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Quick
import Nimble
import Feathers
import PromiseKit

class ServiceSpec: QuickSpec {

    override func spec() {

        describe("Service") {

            var app: Feathers!
            var service: Service!

            beforeEach {
                app = Feathers(provider: StubProvider(data: ["name": "Bob"]))
                service = app.service(path: "users")
            }

            it("should stub the request") {
                var error: Error?
                var response: Response?
                var data: [String: String]?
                service.request(.find(parameters: nil))
                    .then { value -> Promise<Void> in
                        response = value
                        data = value.data.value as? [String: String]
                        return Promise(value: ())
                    }.catch {
                        error = $0
                }
                expect(error).toEventually(beNil())
                expect(response).toEventuallyNot(beNil())
                expect(data).toEventuallyNot(beNil())
                expect(data).to(equal(["name": "Bob"]))
            }

            describe("Hooks") {

                context("before") {

                    var beforeHooks: Service.Hooks!

                    beforeEach {
                        beforeHooks = Service.Hooks(all: [StubHook(data: .jsonObject(["name": "Henry"]))])
                        service.hooks(before: beforeHooks)
                    }

                    it("should run the before hook and skip the request") {
                        var error: Error?
                        var response: Response?
                        var data: [String: String]?
                        service.request(.find(parameters: nil))
                            .then { value -> Promise<Void> in
                                response = value
                                data = value.data.value as? [String: String]
                                return Promise(value: ())
                            }.catch {
                                error = $0
                        }
                        expect(error).toEventually(beNil())
                        expect(response).toEventuallyNot(beNil())
                        expect(data).toEventuallyNot(beNil())
                        expect(data).to(equal(["name": "Henry"]))
                    }

                }

                context("after") {

                    var afterHooks: Service.Hooks!

                    beforeEach {
                        afterHooks = Service.Hooks(all: [PopuplateDataAfterHook(data: ["name": "Susie"])])
                        service.hooks(after: afterHooks)
                    }

                    it("should change the response") {
                        var error: Error?
                        var response: Response?
                        var data: [String: String]?
                        service.request(.find(parameters: nil))
                            .then { value -> Promise<Void> in
                                response = value
                                data = value.data.value as? [String: String]
                                return Promise(value: ())
                            }.catch {
                                error = $0
                        }
                        expect(error).toEventually(beNil())
                        expect(response).toEventuallyNot(beNil())
                        expect(data).toEventuallyNot(beNil())
                        expect(data).to(equal(["name": "Susie"]))
                    }

                }

                context("error") {

                    var beforeHooks: Service.Hooks!

                    beforeEach {
                        // Force the hook to error with ErrorHook
                        beforeHooks = Service.Hooks(all: [ErrorHook(error: .unknown)])
                        service.hooks(before: beforeHooks)
                    }

                    context("when a hook rejects with an error") {

                        it("should pass through the original error") {
                            var error: FeathersError?
                            var response: Response?
                            var data: [String: String]?
                            service.request(.find(parameters: nil))
                                .then { value -> Promise<Void> in
                                    response = value
                                    data = value.data.value as? [String: String]
                                    return Promise(value: ())
                                }.catch {
                                    error = $0 as? FeathersError
                            }
                            expect(error).toEventuallyNot(beNil())
                            expect(error).toEventually(equal(FeathersError.unknown))
                            expect(response).toEventually(beNil())
                            expect(data).toEventually(beNil())
                        }

                        context("when given an error hook that rejects with an error") {

                            var errorHooks: Service.Hooks!

                            beforeEach {
                                errorHooks = Service.Hooks(all: [ErrorHook(error: .unavailable), ErrorHook(error: .unknown)])
                                service.hooks(error: errorHooks)
                            }

                            it("should be able to modify the final error and skip the rest of the chain") {
                                var error: FeathersError?
                                var response: Response?
                                var data: [String: String]?
                                service.request(.find(parameters: nil))
                                    .then { value -> Promise<Void> in
                                        response = value
                                        data = value.data.value as? [String: String]
                                        return Promise(value: ())
                                    }.catch {
                                        error = $0 as? FeathersError
                                }
                                expect(error).toEventuallyNot(beNil())
                                expect(error).toEventually(equal(FeathersError.unavailable))
                                expect(response).toEventually(beNil())
                                expect(data).toEventually(beNil())
                            }

                        }

                        context("when given an error hook that modifies the hook error") {

                            var errorHooks: Service.Hooks!

                            beforeEach {
                                errorHooks = Service.Hooks(all: [ModifyErrorHook(error: .unavailable)])
                                service.hooks(error: errorHooks)
                            }

                            it("should be able to modify the final error") {
                                var error: FeathersError?
                                var response: Response?
                                var data: [String: String]?
                                service.request(.find(parameters: nil))
                                    .then { value -> Promise<Void> in
                                        response = value
                                        data = value.data.value as? [String: String]
                                        return Promise(value: ())
                                    }.catch {
                                        error = $0 as? FeathersError
                                }
                                expect(error).toEventuallyNot(beNil())
                                expect(error).toEventually(equal(FeathersError.unavailable))
                                expect(response).toEventually(beNil())
                                expect(data).toEventually(beNil())
                            }

                            context("with multiple error hooks that modify the error ") {

                                beforeEach {
                                    service.hooks(error: Service.Hooks(all: [ModifyErrorHook(error: .unknown)]))
                                }

                                it("should pass back the final error") {
                                    var error: FeathersError?
                                    var response: Response?
                                    var data: [String: String]?
                                    service.request(.find(parameters: nil))
                                        .then { value -> Promise<Void> in
                                            response = value
                                            data = value.data.value as? [String: String]
                                            return Promise(value: ())
                                        }.catch {
                                            error = $0 as? FeathersError
                                    }
                                    expect(error).toEventuallyNot(beNil())
                                    expect(error).toEventually(equal(FeathersError.unknown))
                                    expect(response).toEventually(beNil())
                                    expect(data).toEventually(beNil())
                                }

                            }
                            
                        }

                    }

                }

            }

        }

    }
    
}
