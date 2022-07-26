//
//  Router.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/10/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

/// Router WebApp for routing requests to different WebApp
open class Router: WebApp {
    var routes: [String: WebApp] = [:]
    open var notFoundResponse: WebApp = DataResponse(
        statusCode: 404,
        statusMessage: "Not found"
    )
    private let semaphore = DispatchSemaphore(value: 1)

    public init() {
    }

    open subscript(path: String) -> WebApp? {
        get {
            // enter critical section
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            defer {
                semaphore.signal()
            }
            return routes[path]
        }

        set {
            // enter critical section
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            defer {
                semaphore.signal()
            }
            routes[path] = newValue!
        }
    }

    open func app(
        _ environ: [String: Any],
        startResponse: @escaping ((String, [(String, String)]) -> Void),
        sendBody: @escaping ((Data) -> Void)
    ) {
        let path = environ["PATH_INFO"] as! String

        if let (webApp, captures) = matchRoute(to: path) {
            var environ = environ
            environ["ambassador.router_captures"] = captures
            webApp.app(environ, startResponse: startResponse, sendBody: sendBody)
            return
        }
        return notFoundResponse.app(environ, startResponse: startResponse, sendBody: sendBody)
    }

    private func matchRoute(to searchPath: String) -> (WebApp, [String])? {
        for (path, route) in routes {
            let regex = try! NSRegularExpression(pattern: path, options: [])
            let matches = regex.matches(
                in: searchPath,
                options: [],
                range: NSRange(location: 0, length: searchPath.count)
            )
            if !matches.isEmpty {
                let searchPath = NSString(string: searchPath)
                let match = matches[0]
                var captures = [String]()
                for rangeIdx in 1 ..< match.numberOfRanges {
                    captures.append(searchPath.substring(with: match.range(at: rangeIdx)))
                }
                return (route, captures)
            }
        }
        return nil
    }
}
