// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Feathers",
    products: [
        .library(name: "Feathers", targets: [
          "Feathers"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "3.1.0"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "11.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.3.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.1.2"),
    ],
    targets: [
        .target(name: "Feathers", dependencies: [
          "KeychainSwift",
          "ReactiveSwift",
          "Security"
        ], path: "Feathers"),
        .testTarget(name: "FeathersTests", dependencies: [
          "Feathers",
          "Quick",
          "Nimble"], path: "FeathersTests")
    ],
    swiftLanguageVersions: [4]
)
