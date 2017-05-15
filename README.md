# FeathersSwift

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/Feathers.svg)](#cocoapods) [![GitHub release](https://img.shields.io/github/release/startupthekid/feathers-ios.svg)](https://github.com/startupthekid/feathers-ios/releases) ![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS-lightgrey.svg)

![feathers](https://media.giphy.com/media/Fn8LZVVgTqXba/giphy.gif)

## What is FeathersSwift?

FeathersSwift is a Cocoa networking library for interacting with a [FeathersJS](https://feathersjs.com/) backend.
Why should you use it?

* Swift 3 :thumbsup:
* Network abstraction layer
* Reactive extensions (ReactiveSwift and RxSwift)
* Integrates seemlessly with any FeathersJS services
* Supports iOS, macOS, and tvOS

If you use FeathersJS (which you should), FeathersSwift is the perfect choice for you. No more dealing with HTTP requests or socket clients. One simple interface to rule them all and in the darkness, unify them :ring:.

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

### Hooks

![hooks](https://media.giphy.com/media/ujGSCZeZs2yXu/giphy.gif)

Like in FeathersJS, you can register `before`, `after`, and `error` hooks to run when requests are made. Possible use cases could include stubbing out a unit test with a before hook or simple logging.

To create a hook, create an object that conforms to `Hook`:

```swift
public protocol Hook {
    func run(with hookObject: HookObject, _ next: @escaping (HookObject) -> ())
}
```

A hook that looks all `create` events might look like this:

```swift
struct CreateLogHook: Hook {

  func run(with hookObject: HookObject, _ next: @escaping (HookObject) -> ()) {
    var object = hookObject
    if object.method == .create {
      print("create happened")
    }
    next(object)
  }

}
```

There are two things to note here. One, `var object = hookObject`. Swift function parameters are `let` constants so you first have to copy the object. Second, the next block. Because promises aren't standard in Cocoa, hooks use an ExpressJS-like middleware system, using a next block to process a chain of hooks. You **must** call `next` with the hook object.

#### Hook Object

The hook object gets passed around through hooks in succession. The interface matches the JS one fairly closely:

```swift
/// Hook object that gets passed through hook functions
public struct HookObject {

    /// Represents the kind of hook.
    ///
    /// - before: Hook is run before the request is made.
    /// - after: Hook is run after the request is made.
    /// - error: Runs when there's an error.
    public enum Kind {
        case before, after, error
    }

    /// The kind of hook.
    public let type: Kind

    /// Feathers application, used to retrieve other services.
    public let app: Feathers

    /// The service this hook currently runs on.
    public let service: Service

    /// The service method.
    public let method: Service.Method

    /// The service method parameters.
    public var parameters: [String: Any]?

    /// The request data.
    public var data: [String: Any]?

    /// The id (for get, remove, update and patch).
    public var id: String?

    /// Error that can be set which will stop the hook processing chain and run a special chain of error hooks.
    public var error: Error?

    /// Result of a successful method call, only in after hooks.
    public var result: Response?

    public init(
        type: Kind,
        app: Feathers,
        service: Service,
        method: Service.Method) {
        self.type = type
        self.app = app
        self.service = service
        self.method = method
    }

}
```

All the `var` declarations are mutable and you can set and mutate them as needed in your hooks.

Important things to note about the hook object:
- Setting `error` will cause the hook processing chain to stop and immediately run any error hooks. If that happens in a `before` hook, the request will also be skipped.
- Setting `result` to some `Response` value in a `before` hook will skip the request, essentially stubbing it.

#### Hook Registration

To register your hooks, you first have to create a `Service.Hooks` object:

```swift
let beforeHooks = Service.Hooks(all: [LogResultHook()], create: [AppendUserIdHook()]])
let afterHooks = Service.Hooks(find: [SaveInRealmHook()])
let errorHooks = Service.Hooks(all: [LogErrorHook(destination: "log.txt")])
```

Registering the hooks then is easy:

```swift
let service = app.service("users")
service.hooks(
  before: beforeHooks,
  after: afterHooks,
  error: errorHooks
)
```

**Important**: The hooks registered for `all` are run first, then the hooks for the particular service method.

### Reactive Extensions

FeathersSwift also providers reactive extensions for ReactiveSwift and RxSwift.

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

If you like the library, please :star: it!

### Further Help

FeathersSwift is extensively documented so please take a look at the source code if you have any questions about how something works.
You can also ping me in the [Feathers' slack team](http://slack.feathersjs.com/) @brendan.

Cheers! :beers:
