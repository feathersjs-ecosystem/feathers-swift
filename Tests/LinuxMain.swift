import XCTest
import Quick

@testable import FeathersTests

Quick.QCKMain([
    FeathersSpec.self,
    QuerySpec.self,
    ServiceSpec.self
])
