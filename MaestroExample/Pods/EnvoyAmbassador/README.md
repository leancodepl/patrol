# Ambassador

[![Build Status](https://travis-ci.org/envoy/Ambassador.svg?branch=master)](https://travis-ci.org/envoy/Ambassador)
[![CocoaPods](https://img.shields.io/cocoapods/v/EnvoyAmbassador.svg)]()
[![Code Climate](https://codeclimate.com/repos/575b39108524ed0091001237/badges/4c5ceffe02f98eb2159d/gpa.svg)](https://codeclimate.com/repos/575b39108524ed0091001237/feed)
[![Issue Count](https://codeclimate.com/repos/575b39108524ed0091001237/badges/4c5ceffe02f98eb2159d/issue_count.svg)](https://codeclimate.com/repos/575b39108524ed0091001237/feed)
[![GitHub license](https://img.shields.io/github/license/envoy/Ambassador.svg)](https://github.com/envoy/Ambassador/blob/master/LICENSE)

Super lightweight web framework in Swift based on [SWSGI](https://github.com/envoy/Embassy#whats-swsgi-swift-web-server-gateway-interface)

## Features

 - Super lightweight
 - Easy to use, designed for UI automatic testing API mocking
 - Based on [SWSGI](https://github.com/envoy/Embassy#whats-swsgi-swift-web-server-gateway-interface), can run with HTTP server other than [Embassy](https://github.com/envoy/Embassy)
 - Response handlers designed as middlewares, easy to composite
 - Async friendly

## Example

Here's an example how to mock API endpoints with Ambassador and [Embassy](https://github.com/envoy/Embassy) as the HTTP server.

```Swift
import Embassy
import EnvoyAmbassador

let loop = try! SelectorEventLoop(selector: try! KqueueSelector())
let router = Router()
let server = DefaultHTTPServer(eventLoop: loop, port: 8080, app: router.app)

router["/api/v2/users"] = DelayResponse(JSONResponse(handler: { _ -> Any in
    return [
        ["id": "01", "name": "john"],
        ["id": "02", "name": "tom"]
    ]
}))

// Start HTTP server to listen on the port
try! server.start()

// Run event loop
loop.runForever()
```

Then you can visit [http://[::1]:8080/api/v2/users](http://[::1]:8080/api/v2/users) in the browser, or use HTTP client to GET the URL and see

```
[
  {
    "id" : "01",
    "name" : "john"
  },
  {
    "id" : "02",
    "name" : "tom"
  }
]
```

## Router

`Router` allows you to map different path to different `WebApp`. Like what you saw in the previous example, to route path `/api/v2/users` to our response handler, you simply set the desired path with the `WebApp` as the value

```Swift
let router = Router()
router["/api/v2/users"] = DelayResponse(JSONResponse(handler: { _ -> Any in
    return [
        ["id": "01", "name": "john"],
        ["id": "02", "name": "tom"]
    ]
}))
```

and pass `router.app` as the SWSGI interface to the HTTP server. When the visit path is not found, `router.notFoundResponse` will be used, it simply returns 404. You can overwrite the `notFoundResponse` to customize the not found behavior.

You can also map URL with regular expression. For example, you can write this

```Swift
let router = Router()
router["/api/v2/users/([0-9]+)"] = DelayResponse(JSONResponse(handler: { environ -> Any in
    let captures = environ["ambassador.router_captures"] as! [String]
    return ["id": captures[0], "name": "john"]
}))
```

Then all requests with URL matching `/api/v2/users/([0-9]+)` regular expression will be routed here. For all match groups, they will be passed into environment with key `ambassador.router_captures` as an array of string.


## DataResponse

`DataResponse` is a helper for sending back data. For example, say if you want to make an endpoint to return status code 500, you can do

```Swift
router["/api/v2/return-error"] = DataResponse(statusCode: 500, statusMessage: "server error")
```

Status is `200 OK`, and content type is `application/octet-stream` by default, they all can be overwritten via init parameters. You can also provide custom headers and a handler for returning the data. For example:

```Swift
router["/api/v2/xml"] = DataResponse(
    statusCode: 201,
    statusMessage: "created",
    contentType: "application/xml",
    headers: [("X-Foo-Bar", "My header")]
) { environ -> Data in
    return Data("<xml>who uses xml nowadays?</xml>".utf8)
}
```

If you prefer to send body back in async manner, you can also use another init that comes with extra `sendData` function as parameter

```Swift
router["/api/v2/xml"] = DataResponse(
    statusCode: 201,
    statusMessage: "created",
    contentType: "application/xml",
    headers: [("X-Foo-Bar", "My header")]
) { (environ, sendData) in
    sendData(Data("<xml>who uses xml nowadays?</xml>".utf8))
}
```

Please notice, unlike `sendBody` for SWSGI, `sendData` only expects to be called once with the whole chunk of data.

## JSONResponse

Almost identical to `DataResponse`, except it takes `Any` instead of bytes and dump the object as JSON format and response it for you. For example:

```Swift
router["/api/v2/users"] = JSONResponse() { _ -> Any in
    return [
        ["id": "01", "name": "john"],
        ["id": "02", "name": "tom"]
    ]
}
```

## DelayResponse

`DelayResponse` is a **decorator** response that delays given response for a while. In real-world, there will always be network latency, to simulte the latency, `DelayResponse` is very helpful. To delay a response, just do

```Swift
router["/api/v2/users"] = DelayResponse(JSONResponse(handler: { _ -> Any in
    return [
        ["id": "01", "name": "john"],
        ["id": "02", "name": "tom"]
    ]
}))
```

By default, it delays the response randomly. You can modify it by passing `delay` parameter. Like, say if you want to delay it for 10 seconds, then here you do

```Swift
router["/api/v2/users"] = DelayResponse(JSONResponse(handler: { _ -> Any in
    return [
        ["id": "01", "name": "john"],
        ["id": "02", "name": "tom"]
    ]
}), delay: .delay(10))
```

The available delay options are

 - **.random(min: TimeInterval, max: TimeInterval)** delay random, it's also the default one as .random(min: 0.1, max: 3)
 - **.delay(seconds: TimeInterval)** delay specific period of time
 - **.never** delay forever, the response will never be returned
 - **.none** no delay, i.e. the response will be returned immediately

## DataReader

To read POST body or any other HTTP body from the request, you need to use `swsgi.input` function provided in the `environ` parameter of SWSGI. For example, you can do it like this

```Swift
router["/api/v2/users"] = JSONResponse() { environ -> Any in
    let input = environ["swsgi.input"] as! SWSGIInput
    input { data in
        // handle the data stream here
    }
}
```

It's not too hard to do so, however, the data comes in as stream, like

- "first chunk"
- "second chunk"
- ....
- "" (empty data array indicates EOF)

In most cases, you won't like to handle the data stream manually. To wait all data received and process them at once, you can use `DataReader`. For instance

```Swift
router["/api/v2/users"] = JSONResponse() { environ -> Any in
    let input = environ["swsgi.input"] as! SWSGIInput
    DataReader.read(input) { data in
        // handle the whole data here
    }
}
```

## JSONReader

Like `DataReader`, besides reading the whole chunk of data, `JSONReader` also parses it as JSON format. Herer's how you do

```Swift
router["/api/v2/users"] = JSONResponse() { environ -> Any in
    let input = environ["swsgi.input"] as! SWSGIInput
    JSONReader.read(input) { json in
        // handle the json object here
    }
}
```

## URLParametersReader

`URLParametersReader` waits all data to be received and parses them all at once as URL encoding parameters, like `foo=bar&eggs=spam`. The parameters will be passed as an array key value pairs as `(String, String)`.

```Swift
router["/api/v2/users"] = JSONResponse() { environ -> Any in
    let input = environ["swsgi.input"] as! SWSGIInput
    URLParametersReader.read(input) { params in
        // handle the params object here
    }
}
```

You can also use `URLParametersReader.parseURLParameters` to parse the URL encoded parameter string if you want. Just do it like

```Swift
let params = URLParametersReader.parseURLParameters("foo=bar&eggs=spam")
```

## Install

### CocoaPods

To install with CocoaPod, add Embassy to your Podfile:

```
pod 'EnvoyAmbassador', '~> 4.0'
```

### Carthage

To install with Carthage, add Ambassador to your Cartfile:

```
github "envoy/Ambassador" ~> 4.0
```

Please notice that you should import `Ambassador` instead of `EnvoyAmbassador`. We use `EnvoyAmbassador` for Cocoapods simply because the name `Ambassador` was already taken.

### Package Manager

To do this, add the repo to `Package.swift`, like this:

```swift
import PackageDescription

let package = Package(
    name: "AmbassadorExample",
    dependencies: [
        .package(url: "https://github.com/envoy/Ambassador.git",
                 from: "4.0.0"),
    ]
)
```
