# Feathers

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/Feathers.svg)](#cocoapods) [![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-orange.svg)](#swift-package-manager) [![GitHub release](https://img.shields.io/github/release/startupthekid/feathers-ios.svg)](https://github.com/startupthekid/feathers-ios/releases) ![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS-lightgrey.svg)


## What is Feathers?

Feathers is a Swift 3 compliant SDK for interacting with a FeathersJS backend. Feathers makes it easy to integrate with any Feathers services on the backend, providing REST and SocketIO transport providers.

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
## Getting Started

Create an instance of a `Feathers` application with the desired provider:

```swift

let feathersRestApp = Feathers(RestProvider(baseURL: URL(string: "https://myserver.com")))

```

Then grab a service:

```swift
let userService = feathersRestApp.service("users")
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
public enum Method {

    case find(parameters: [String: Any]?)
    case get(id: String, parameters: [String: Any]?)
    case create(data: [String: Any], parameters: [String: Any]?)
    case update(id: String?, data: [String: Any], parameters: [String: Any]?)
    case patch(id: String?, data: [String: Any], parameters: [String: Any]?)
    case remove(id: String?, parameters: [String: Any]?)

}
```

With `.update`, `.patch`, and `.remove`, you may pass in nil for the id when you want to delete a list of entities. The list of entities is determined by the query parameters you pass in.

### Authentication

To authenticate your application with your Feathers back end:

```swift
feathersRestApp.authenticate([
  "strategy": "facebook-token",
  "access_token": "ACCESS_TOKEN"
])
```

Authentication returns a JWT payload which is cached by the application and used to make subsequent requests. Currently there is not a re-authentication mechanism but look for that in coming versions.

To log out, simply call:

```swift
feathersRestApp.logout { error, response in

}
```

### Real-Time Events

When using the socket provider, you can not only use it to call Feathers service methods, you can also listen for real-time events. Simply create a feathers application with an instance of `SocketProvider` and register for events using `.on` on your services.

There are four different real-time events:

```swift
public enum RealTimeEvent: String {

   case created = "created"
   case updated = "updated"
   case patched = "patched"
   case removed = "removed"

}
```

You can use these events to things like dynamically update the UI, save entities to a database, or just log that the event happened.

```swift
let feathersSocket = Feathers(provider: SocketProvider(baseURL: URL(string: "https://myserver.com")!, configuration: []))

let userService = feathersSocket.service(path: "users")
userService.on(.created) { entity in
  print(entity) // Prints the object that was just created
}
```

When you're finished, be sure to call `.off` to unregister from the event. Otherwise your completion block will be retained by the provider.

```swift
userService.off(.created)
```

### Reactive Extensions

Feathers also providers reactive extensions for ReactiveSwift and RxSwift.

To install via Cocoapods:

```
pod 'Feathers/ReactiveSwift'
pod 'Feathers/RxSwift'
```

With Carthage, just drag in the frameworks.

There are reactive extensions for the following classes and methods:

- `Service`
  - `request`
  - `on`
- `Feathers`
  - `authenticate`
  - `logout`

### Contributing

Have an issue? Open an issue! Have an idea? Open a pull request!

### Further Help

Feathers is extensively documented so please take a look at the source code if you have any questions about how something works.
You can also ping me in the [Feathers' slack team](https://slack.feathersjs.com) @brendan.

Cheers! :beers:
