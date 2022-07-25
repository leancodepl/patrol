# Embassy

[![Build Status](https://travis-ci.org/envoy/Embassy.svg?branch=master)](https://travis-ci.org/envoy/Embassy)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![CocoaPods](https://img.shields.io/cocoapods/v/Embassy.svg)]()
![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Plaform](https://img.shields.io/badge/Platform-macOS|iOS|Linux-lightgrey.svg)
[![GitHub license](https://img.shields.io/github/license/envoy/Embassy.svg)](https://github.com/envoy/Embassy/blob/master/LICENSE)

Super lightweight async HTTP server in pure Swift.

**Please read**: [Embedded web server for iOS UI testing](https://envoy.engineering/embedded-web-server-for-ios-ui-testing-8ff3cef513df#.c2i5tx380).

**See also**: Our lightweight web framework [Ambassador](https://github.com/envoy/Ambassador) based on Embassy

## Features

 - Swift 4 & 5
 - iOS / tvOS / MacOS / Linux
 - Super lightweight, only 1.5 K of lines
 - Zero third-party dependency
 - Async event loop based HTTP server, makes long-polling, delay and bandwidth throttling all possible
 - HTTP Application based on [SWSGI](#whats-swsgi-swift-web-server-gateway-interface), super flexible
 - IPV6 ready, also supports IPV4 (dual stack)
 - Automatic testing covered

## Example

Here's a simple example shows how Embassy works.

```Swift
let loop = try! SelectorEventLoop(selector: try! KqueueSelector())
let server = DefaultHTTPServer(eventLoop: loop, port: 8080) {
    (
        environ: [String: Any],
        startResponse: ((String, [(String, String)]) -> Void),
        sendBody: ((Data) -> Void)
    ) in
    // Start HTTP response
    startResponse("200 OK", [])
    let pathInfo = environ["PATH_INFO"]! as! String
    sendBody(Data("the path you're visiting is \(pathInfo.debugDescription)".utf8))
    // send EOF
    sendBody(Data())
}

// Start HTTP server to listen on the port
try! server.start()

// Run event loop
loop.runForever()
```

Then you can visit `http://[::1]:8080/foo-bar` in the browser and see

```
the path you're visiting is "/foo-bar"
```

## Async Event Loop

To use the async event loop, you can get it via key `embassy.event_loop` in `environ` dictionary and cast it to `EventLoop`. For example, you can create an SWSGI app which delays `sendBody` call like this

```Swift
let app = { (
    environ: [String: Any],
    startResponse: ((String, [(String, String)]) -> Void),
    sendBody: @escaping ((Data) -> Void)
) in
    startResponse("200 OK", [])

    let loop = environ["embassy.event_loop"] as! EventLoop

    loop.call(withDelay: 1) {
        sendBody(Data("hello ".utf8))
    }
    loop.call(withDelay: 2) {
        sendBody(Data("baby ".utf8))
    }
    loop.call(withDelay: 3) {
        sendBody(Data("fin".utf8))
        sendBody(Data())
    }
}
```

Please notice that functions passed into SWSGI should be only called within the same thread for running the `EventLoop`, they are all not threadsafe, therefore, **you should not use [GCD](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/) for delaying any call**. Instead, there are some methods from `EventLoop` you can use, and they are all threadsafe

### call(callback: (Void) -> Void)

Call given callback as soon as possible in the event loop

### call(withDelay: TimeInterval, callback: (Void) -> Void)

Schedule given callback to `withDelay` seconds then call it in the event loop.

### call(atTime: Date, callback: (Void) -> Void)

Schedule given callback to be called at `atTime` in the event loop. If the given time is in the past or zero, this methods works exactly like `call` with only callback parameter.

## What's SWSGI (Swift Web Server Gateway Interface)?

SWSGI is a hat tip to Python's [WSGI (Web Server Gateway Interface)](https://www.python.org/dev/peps/pep-3333/). It's a gateway interface enables web applications to talk to HTTP clients without knowing HTTP server implementation details.

It's defined as

```Swift
public typealias SWSGI = (
    [String: Any],
    @escaping ((String, [(String, String)]) -> Void),
    @escaping ((Data) -> Void)
) -> Void
```

### `environ`

It's a dictionary contains all necessary information about the request. It basically follows WSGI standard, except `wsgi.*` keys will be `swsgi.*` instead. For example:

```Swift
[
  "SERVER_NAME": "[::1]",
  "SERVER_PROTOCOL" : "HTTP/1.1",
  "SERVER_PORT" : "53479",
  "REQUEST_METHOD": "GET",
  "SCRIPT_NAME" : "",
  "PATH_INFO" : "/",
  "HTTP_HOST": "[::1]:8889",
  "HTTP_USER_AGENT" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36",
  "HTTP_ACCEPT_LANGUAGE" : "en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2",
  "HTTP_CONNECTION" : "keep-alive",
  "HTTP_ACCEPT" : "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "HTTP_ACCEPT_ENCODING" : "gzip, deflate, sdch",
  "swsgi.version" : "0.1",
  "swsgi.input" : (Function),
  "swsgi.error" : "",
  "swsgi.multiprocess" : false,
  "swsgi.multithread" : false,
  "swsgi.url_scheme" : "http",
  "swsgi.run_once" : false
]
```

To read request from body, you can use `swsgi.input`, for example

```Swift
let input = environ["swsgi.input"] as! SWSGIInput
input { data in
    // handle the body data here
}
```

An empty Data will be passed into the input data handler when EOF
reached. Also please notice that, request body won't be read if `swsgi.input`
is not set or set to nil. You can use `swsgi.input` as bandwidth control, set
it to nil when you don't want to receive any data from client.

Some extra Embassy server specific keys are

 - `embassy.connection` - `HTTPConnection` object for the request
 - `embassy.event_loop` - `EventLoop` object
 - `embassy.version` - Version of embassy as a String, e.g. `3.0.0`

### `startResponse`

Function for starting to send HTTP response header to client, the first argument is status code with message, e.g. "200 OK". The second argument is headers, as a list of key value tuple.

To response HTTP header, you can do

```Swift
startResponse("200 OK", [("Set-Cookie", "foo=bar")])
```

`startResponse` can only be called once per request, extra call will be simply ignored.

### `sendBody`

Function for sending body data to client. You need to call `startResponse` first in order to call `sendBody`. If you don't call `startResponse` first, all calls to `sendBody` will be ignored. To send data, here you can do

```Swift
sendBody(Data("hello".utf8))
```

To end the response data stream simply call `sendBody` with an empty Data.

```Swift
sendBody(Data())
```

## Install

### CocoaPods

To install with CocoaPod, add Embassy to your Podfile:

```
pod 'Embassy', '~> 4.1'
```

### Carthage

To install with Carthage, add Embassy to your Cartfile:

```
github "envoy/Embassy" ~> 4.1
```

### Package Manager

Add it this Embassy repo in `Package.swift`, like this

```swift
import PackageDescription

let package = Package(
    name: "EmbassyExample",
    dependencies: [
        .package(url: "https://github.com/envoy/Embassy.git",
                 from: "4.1.1"),
    ]
)
```

You can read this [example project](https://github.com/envoy/example-embassy) here.
