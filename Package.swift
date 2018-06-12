// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "FeathersSwift",
    products: [
        .library(name: "FeathersSwift", targets: ["FeathersSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/ReactiveSwift.git", from: "3.1.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.3.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.1.2"),
    ],
    targets: [
        .target(name: "FeathersSwift", dependencies: ["Result"], path: "Core"),
        .testTarget(name: "FeathersSwiftTests", dependencies: ["Feathers", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [4]
)
