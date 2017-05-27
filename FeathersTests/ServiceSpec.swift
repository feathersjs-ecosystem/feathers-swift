//
//  ServiceSpec.swift
//  Feathers
//
//  Created by Brendan Conron on 5/18/17.
//  Copyright © 2017 FeathersJS. All rights reserved.
//

import Quick
import Nimble
import Feathers

class ServiceSpec: QuickSpec {

    override func spec() {

        describe("Service") {

            var app: Feathers!
            var service: ServiceType!

            beforeEach {
                app = Feathers(provider: StubProvider(data: ["name": "Bob"]))
                service = app.service(path: "users")
            }

            it("should stub the request") {
                print(service)
                var error: Error?
                var response: Response?
                var data: [String: String]?
                service.request(.find(query: nil))
                    .on(failed: {
                        error = $0
                    }, value: {
                        response = $0
                        data = $0.data.value as? [String: String]
                        print($0)
                    })
                    .start()
                expect(error).toEventually(beNil())
                expect(response).toEventuallyNot(beNil())
                expect(data).toEventuallyNot(beNil())
                expect(data).to(equal(["name": "Bob"]))
            }

            describe("Hooks") {

                context("before") {

                    var beforeHooks: Service.Hooks!

                    beforeEach {
                        beforeHooks = Service.Hooks(all: [StubHook(data: .object(["name": "Henry"]))])
                        service.hooks(before: beforeHooks, after: nil, error: nil)
                    }

                    it("should run the before hook and skip the request") {
                        var error: Error?
                        var response: Response?
                        var data: [String: String]?
                        service.request(.find(query: nil))
                            .on(failed: {
                                error = $0
                            }, value: {
                                response = $0
                                data = $0.data.value as? [String: String]
                            })
                            .start()
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
                        service.hooks(before: nil, after: afterHooks, error: nil)
                    }

                    it("should change the response") {
                        var error: Error?
                        var response: Response?
                        var data: [String: String]?
                        service.request(.find(query: nil))
                            .on(failed: {
                                error = $0
                            }, value: {
                                response = $0
                                data = $0.data.value as? [String: String]
                            })
                            .start()
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
                        beforeHooks = Service.Hooks(all: [ErrorHook(error:FeathersNetworkError.unknown)])
                        service.hooks(before: beforeHooks, after: nil, error: nil)
                    }

                    context("when a hook rejects with an error") {

                        it("should pass through the original error") {
                            var error: FeathersNetworkError?
                            var response: Response?
                            var data: [String: String]?
                            service.request(.find(query: nil))
                                .on(failed: {
                                    error = $0.error as? FeathersNetworkError
                                }, value: {
                                    response = $0
                                    data = $0.data.value as? [String: String]
                                })
                                .start()
                            expect(error).toEventuallyNot(beNil())
                            expect(error).toEventually(equal(FeathersNetworkError.unknown))
                            expect(response).toEventually(beNil())
                            expect(data).toEventually(beNil())
                        }

                        context("when given an error hook that rejects with an error") {

                            var errorHooks: Service.Hooks!

                            beforeEach {
                                errorHooks = Service.Hooks(all: [ErrorHook(error: FeathersNetworkError.unavailable), ErrorHook(error: FeathersNetworkError.unknown)])
                                service.hooks(before: nil, after: nil, error: errorHooks)
                            }

                            it("should be able to modify the final error and skip the rest of the chain") {
                                var error: FeathersNetworkError?
                                var response: Response?
                                var data: [String: String]?
                                service.request(.find(query: nil))
                                    .on(failed: {
                                        error = $0.error as? FeathersNetworkError
                                    }, value: {
                                        response = $0
                                        data = $0.data.value as? [String: String]
                                    })
                                    .start()
                                expect(error).toEventuallyNot(beNil())
                                expect(error).toEventually(equal(FeathersNetworkError.unavailable))
                                expect(response).toEventually(beNil())
                                expect(data).toEventually(beNil())
                            }

                        }

                        context("when given an error hook that modifies the hook error") {

                            var errorHooks: Service.Hooks!

                            beforeEach {
                                errorHooks = Service.Hooks(all: [ModifyErrorHook(error: FeathersNetworkError.unavailable)])
                                service.hooks(before: nil, after: nil, error: errorHooks)
                            }

                            it("should be able to modify the final error") {
                                var error: FeathersNetworkError?
                                var response: Response?
                                var data: [String: String]?
                                service.request(.find(query: nil))
                                    .on(failed: {
                                        error = $0.error as? FeathersNetworkError
                                    }, value: {
                                        response = $0
                                        data = $0.data.value as? [String: String]
                                    })
                                    .start()
                                expect(error).toEventuallyNot(beNil())
                                expect(error).toEventually(equal(FeathersNetworkError.unavailable))
                                expect(response).toEventually(beNil())
                                expect(data).toEventually(beNil())
                            }

                            context("with multiple error hooks that modify the error ") {

                                beforeEach {
                                    service.hooks(before: nil, after: nil, error: Service.Hooks(all: [ModifyErrorHook(error: FeathersNetworkError.unknown)]))
                                }

                                it("should pass back the final error") {
                                    var error: FeathersNetworkError?
                                    var response: Response?
                                    var data: [String: String]?
                                    service.request(.find(query: nil))
                                        .on(failed: {
                                            error = $0.error as? FeathersNetworkError
                                        }, value: {
                                            response = $0
                                            data = $0.data.value as? [String: String]
                                        })
                                        .start()
                                    expect(error).toEventuallyNot(beNil())
                                    expect(error).toEventually(equal(FeathersNetworkError.unknown))
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
