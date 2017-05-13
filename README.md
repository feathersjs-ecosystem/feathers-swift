# Feathers


[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/Feathers.svg)](#cocoapods) [![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-orange.svg)](#swift-package-manager) [![GitHub release](https://img.shields.io/github/release/startupthekid/feathers-ios.svg)](https://github.com/startupthekid/feathers-ios/releases) ![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS-lightgrey.svg)


A Swifty library for interacting with a FeatherJS backend with ease.


## Installation

### Cocoapods
```
pod `Feathers`
```

### Carthage

Add the following line to your Cartfile:

```
github "startupthekid/feathers-ios"
```
## Usage

Create an instance of a `Feathers` application with the desired provider:

```swift
struct Providers {
    static let feathersRestApp = Feathers(RestProvider(baseURL: URL(string: "https://myserver.com")))
}
```

Then grab a service:

```swift
let userService = Providers.feathersRestApp.service("users")
```

Finally, make a request:

```swift
service.request(.find(parameters: ["name": "Bob"])) { error, response in
  if let error = error {
    // Do something with the error
  } else if let response = response {
      print(response.data)
  }
}
```

There are six types of requests you can make that correspond with Feathers service methods:

```swift
public enum FeathersMethod {

    case find(parameters: [String: Any]?)
    case get(id: String, parameters: [String: Any]?)
    case create(data: [String: Any], parameters: [String: Any]?)
    case update(id: String, data: [String: Any], parameters: [String: Any]?)
    case patch(id: String, data: [String: Any], paramters: [String: Any]?)
    case remove(id: String, parameters: [String: Any]?)

}
```

### Authentication

To authenticate your application with your Feathers back end:

```swift
Providers.feathersRestApp.authenticate([
"strategy": "facebook-token",
"access_token": "ACCESS_TOKEN"
])
```

Authentication returns a JWT payload which is cached by the application.
