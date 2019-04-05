# FeathersSwift

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/Feathers.svg)](#cocoapods) [![GitHub release](https://img.shields.io/github/release/feathersjs-ecosystem/feathers-swift.svg)](https://github.com/feathersjs-ecosystem/feathers-swift/releases) ![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg) ![build](https://travis-ci.org/feathersjs-ecosystem/feathers-swift.svg?branch=master)

![feathers](https://media.giphy.com/media/Fn8LZVVgTqXba/giphy.gif)

## What is FeathersSwift?

FeathersSwift is a Cocoa networking library for interacting with a [FeathersJS](https://feathersjs.com/) backend.
Why should you use it?

* Swift 4 :thumbsup:
* Network abstraction layer
* Integrates seemlessly with any FeathersJS services
* Supports iOS, macOS, tvOS, and watchOS
* Reactive API ([ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift))

If you use FeathersJS (which you should), FeathersSwift is the perfect choice for you. No more dealing with HTTP requests or socket clients. One simple interface to rule them all and in the darkness, unify them :ring:.

## Installation

### Cocoapods
```
pod `Feathers`
```

### Carthage

Add the following line to your Cartfile:

```
github "feathersjs/feathers-swift"
```
## Getting Started

FeathersSwift is spread out across multiple repositories to ensure that you're only pulling in exactly what you need and no more. There are two Feathers providers, [feathers-swift-rest](https://github.com/feathersjs-ecosystem/feathers-swift-rest) and [feathers-swift-socketio](https://github.com/feathersjs-ecosystem/feathers-swift-socketio). Install either provider using the instructions on their respective READMEs.

Once you've install a provider, either rest of socketio, an instance of a `Feathers` application with it:

```swift

let feathersRestApp = Feathers(RestProvider(baseURL: URL(string: "https://myserver.com")))

```

Then grab a service:

```swift
let userService = feathersRestApp.service("users")
```

Finally, make a request:

```swift
service.request(.find(parameters: ["name": "Waldo"]))
.on(value: { response in
  print(response)
})
.start()
```

FeathersSwift's API is built entirely using [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift), an awesome functional-reactive library. Because promises aren't standard in Swift, we had to find an alternative that offers similar usage patterns. By doing this, we can avoid the pyramid of doom and endlessly nesting callbacks, instead offering a simplified reactive API.

### Service

There are six types of requests you can make that correspond with Feathers service methods:

```swift
public enum Method {

    case find(query: Query?)
    case get(id: String, query: Query?)
    case create(data: [String: Any], query: Query?)
    case update(id: String?, data: [String: Any], query: Query?)
    case patch(id: String?, data: [String: Any], query: Query?)
    case remove(id: String?, query: Query?)

}
```

With `.update`, `.patch`, and `.remove`, you may pass in nil for the id when you want to delete a list of entities. The list of entities is determined by the query you pass in.

By default, FeathersSwift will return an instance of `ProviderService` which wraps the application's transport provider in a service. However, you can also register your own services:

```swift
feathers.use("users-local", CoreDataService())
```

All custom services must conform to `ServiceType`. Thankfully, that's easy due to the FeathersSwift provided `Service` class which handles things such as hook storage and no-op implementations of the required methods.

A simple custom service might look like:

```swift
class FileService: Service {

  public override func request(_ method: Service.Method) -> SignalProducer<Response, FeathersError> {
        let fileManager = FileManager.default
        switch method {
        case let .create(data, _):
          guard let id = data["id"] else { break }
          let fileData = NSKeyedArchiver.archiveData(withRootObject: data)
          fileManager.createFile(atPath: "\(path)/\(id)", contents: fileData, attributes: nil)
        default: break
        }
    }

}
```

While a tiny example, custom services can be infinitely more complex and used anywhere in the hook process. Just call `hookObject.app.service("my-custom-service").request(.create(data: [:], parameters: nil))`.

### Querying

You may have noticed instead of passing a dictionary of parameters through a request, FeathersSwift uses a `Query` object. The `Query` class has a simple and composable API for represent complex queries without messing around with dictionaries. It supports all the normal queries FeathersJS users have come to know and love such as `ne` or `or`, just in a simplified, type-safe manner.

To create a query:

```swift
let query = Query()
  .ne("age", 50)
  .limit(25)
  .skip(5)

let service = feathers.service("users")

service.request(.find(query)).start()

```

Gone are the days of wondering if you formatted your dictionary correctly, `Query` knows how to serialize itself and takes care of that for you.

### Authentication

To authenticate your application with your Feathers back end:

```swift
feathersRestApp.authenticate([
  "strategy": "facebook-token",
  "access_token": "ACCESS_TOKEN"
])
.start()
```

Authentication returns a JWT payload which is cached by the application and used to make subsequent requests. Currently there is not a re-authentication mechanism but look for that in coming versions.

To log out, simply call:

```swift
feathersRestApp.logout().start()
```

### Real-Time Events

When using the socket provider, you can not only use it to call Feathers service methods, you can also listen for real-time events. Simply use [feathers-swift-socketio](https://github.com/feathersjs/feathers-swift-socketio) create a feathers application with an instance of `SocketProvider` and register for events using `.on` on your services.

There are four different real-time events:

```swift
public enum RealTimeEvent: String {

   case created
   case updated
   case patched
   case removed

}
```

You can use these events to things like dynamically update the UI, save entities to a database, or just log that the event happened.

```swift
let feathersSocket = Feathers(provider: SocketProvider(baseURL: URL(string: "https://myserver.com")!, configuration: []))

let userService = feathersSocket.service(path: "users")
userService.on(.created)
.observeValues { entity in
  print(entity) // Prints the object that was just created
}
```

When you're finished, be sure to call `.off` to unregister from the event. Otherwise your completion block will be retained by the provider.

```swift
userService.off(.created)
```

There's also a nifty `.once` function that does exactly what you expect; you listen for one event and one event only.

### Hooks

![hooks](https://media.giphy.com/media/ujGSCZeZs2yXu/giphy.gif)

Like in FeathersJS, you can register `before`, `after`, and `error` hooks to run when requests are made. Possible use cases could include stubbing out a unit test with a before hook or simple logging.

To create a hook, create an object that conforms to `Hook`:

```swift
public protocol Hook {
    func run(with hookObject: HookObject) -> Promise<HookObject>
}
```

A hook that logs all `create` events might look like this:

```swift
struct CreateLogHook: Hook {

  func run(with hookObject: HookObject) -> Promise<HookObject> {
    var object = hookObject
    if object.method == .create {
      print("create happened")
    }
    return Promise(value: object)
  }

}
```

Or you can do something more complex like a network call:

```swift
struct FetchAssociatedUserHook: Hook {
  func run(with hookObject: HookObject) -> Promise<HookObject> {
    var object = hookObject
    guard object.app.service.path == "groups" else {
      return Promise(value: hookObject)
    }
    guard case var .get(id, parameters)  = object.method else {
      return Promise(value: hookObject)
    }
    guard let userIdentifier = parameters["user_id"] as? String else {
      return Promise(error: .myCustomError("no associated user found when expected to exist"))
    }
    return object.app.service("users").request(.get(parameters: ["id": userIdentifier])).then { response in
      if case let .jsonObject(object) = response.data {
        parameters["user_id"] = object["id"]
        object.method = .get(id, parameters)
      }
      return Promise(value: object)
    }
  }
}
```

Important to note is `var object = hookObject`. Swift function parameters are `let` constants so you first have to copy the object if you want to modify it.

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
    public var method: Service.Method

    /// Error that can be set which will stop the hook processing chain and run a special chain of error hooks.
    public var error: FeathersError?

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

All the `var` declarations are mutable and you can set and mutate them as needed in your hooks, including `.method` if you want to do things like swap out parameters or change the method call entirely (e.g. changing a `.get` to a `.find`).

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

Registering the hooks is just as easy:

```swift
let service = app.service("users")
service.before(beforeHooks)
service.after(afterHooks)
service.error(errorHooks)
```

**Important**: The hooks registered for `all` are run first, then the hooks for the particular service method.

If at any point you need to inspect your hooks, you can do that too using `.hooks`:

```swift

let beforeHooks = service.hooks(for: .before)

```

### Contributing

Have an issue? Open an issue! Have an idea? Open a pull request!

If you like the library, please :star: it!

### Further Help

FeathersSwift is extensively documented so please take a look at the source code if you have any questions about how something works.
You can also ping me in the [Feathers' slack team](http://slack.feathersjs.com/) @brendan.

Cheers! :beers:
