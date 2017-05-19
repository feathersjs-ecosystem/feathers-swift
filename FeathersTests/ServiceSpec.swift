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

        }

    }
    
}
