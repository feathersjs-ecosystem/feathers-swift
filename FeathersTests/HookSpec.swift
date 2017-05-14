//
//  HookSpec.swift
//  Feathers
//
//  Created by Brendan Conron on 5/14/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Quick
import Nimble
import Feathers

class HookSpec: QuickSpec {

    override func spec() {

        describe("Hooks") {

            var app: Feathers!
            var userService: Service!


            describe("before hooks") {

                var beforeHooks: Service.Hooks!

                context("when using a real provider") {

                    var stubData: [String: String]!

                    beforeEach {
                        // Have to use a real provider to make sure we can skip the result
                        app = Feathers(provider: RestProvider(baseURL: URL(string: "https://myserver.com")!))
                        userService = app.service(path: "users")
                        stubData = ["name": "Bob"]
                        beforeHooks = Service.Hooks(all: [StubHook(data: .jsonObject(stubData))])
                        userService.hooks(before: beforeHooks)
                    }

                    context("when any request is made") {

                        it("should stub the response") {
                            var error: FeathersError?
                            var response: Response?
                            var data: ResponseData?
                            var jsonData: [String: String]?
                            userService.request(.get(id: "", parameters: [:])) {
                                error = $0
                                response = $1
                                data = $1?.data
                                jsonData = $1?.data.value as? [String: String]
                            }
                            expect(error).toEventually(beNil())
                            expect(response).toEventuallyNot(beNil())
                            expect(data).toEventuallyNot(beNil())
                            expect(jsonData).toEventuallyNot(beNil())
                            expect(jsonData).toEventually(equal(stubData))
                        }
                        
                    }
                }

                context("when using a stubbed provider") {

                    beforeEach {
                        app = Feathers(provider: StubProvider())
                        userService = app.service(path: "users")
                    }

                    context("when using a before hook as an after/error hook") {

                        beforeEach {
                            beforeHooks = Service.Hooks(all: [StubHook(data: .jsonObject([:]))])
                            userService.hooks(after: beforeHooks)
                        }

                        it("should error") {
                            var error: FeathersError?
                            var response: Response?
                            userService.request(.find(parameters: nil)) {
                                error = $0
                                response = $1
                            }
                            expect(error).toEventuallyNot(beNil())
                            expect(response).toEventually(beNil())

                        }

                    }

                }

            }

            describe("after hooks") {


                var afterHooks: Service.Hooks!
                beforeEach {
                    app = Feathers(provider: StubProvider())
                    userService = app.service(path: "users")
                }

                context("when any request is made") {

                    beforeEach {
                        afterHooks = Service.Hooks(all: [PopuplateDataAfterHook(data: ["name": "Bob"])])
                        userService.hooks(before: nil, after: afterHooks, error: nil)
                    }

                    it("should popuplate the hook data") {
                        var error: FeathersError?
                        var response: Response?
                        var data: ResponseData?
                        var jsonData: [String: String]?
                        userService.request(.get(id: "", parameters: [:])) {
                            error = $0
                            response = $1
                            data = $1?.data
                            jsonData = $1?.data.value as? [String: String]
                        }
                        expect(error).toEventually(beNil())
                        expect(response).toEventuallyNot(beNil())
                        expect(data).toEventuallyNot(beNil())
                        expect(jsonData).toEventuallyNot(beNil())
                        expect(jsonData).toEventually(equal(["name": "Bob"]))
                    }

                }

                context("when a specific method is called") {

                    beforeEach {
                        afterHooks = Service.Hooks(find: [PopuplateDataAfterHook(data: ["name": "Bob"])])
                        userService.hooks(after: afterHooks)
                    }

                    it("should only run the hook for that method") {
                        var error: FeathersError?
                        var response: Response?
                        var jsonData: [String: String]?
                        userService.request(.find(parameters: nil)) {
                            error = $0
                            response = $1
                            jsonData = $1?.data.value as? [String: String]
                        }
                        expect(error).toEventually(beNil())
                        expect(response).toEventuallyNot(beNil())
                        expect(jsonData).toEventually(equal(["name":"Bob"]))
                    }

                    it("should not run the hook (or popuplate the result) for other service methods") {
                        var error: FeathersError?
                        var response: Response?
                        var jsonData: [String: String]?
                        userService.request(.get(id: "", parameters: nil)) {
                            error = $0
                            response = $1
                            jsonData = $1?.data.value as? [String: String]
                        }
                        expect(error).toEventually(beNil())
                        expect(response).toEventuallyNot(beNil())
                        expect(jsonData).toEventuallyNot(equal(["name":"Bob"]))
                    }

                }

                context("when an after only hook is used as a before hook") {

                    beforeEach {
                        userService.hooks(before: afterHooks)
                    }

                    it("should error") {
                        var error: FeathersError?
                        var response: Response?
                        userService.request(.find(parameters: nil)) {
                            error = $0
                            response = $1
                        }
                        expect(error).toEventuallyNot(beNil())
                        expect(response).toEventually(beNil())
                    }

                }

            }

        }

    }

}
