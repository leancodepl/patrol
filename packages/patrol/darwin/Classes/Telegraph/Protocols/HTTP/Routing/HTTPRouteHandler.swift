//
//  HTTPRouteHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/4/17.
//  Copyright © 2017 Building42. All rights reserved.
//

open class HTTPRouteHandler: HTTPRequestHandler {
  public var routes = [HTTPRoute]()
  public var implicitHeadRequests = true

  open func respond(to request: HTTPRequest, nextHandler: HTTPRequest.Handler) throws -> HTTPResponse? {
    var matchingRoute: HTTPRoute?

    // Do we want to allow HEAD requests on GET routes?
    let tryGetForHead = implicitHeadRequests && (request.method == .HEAD)

    for route in routes {
      // Skip routes that can't handle our method
      if !route.canHandle(method: request.method) {

        // Is this a HEAD request and do we want to serve this as a GET request?
        if !tryGetForHead || !route.canHandle(method: .GET) {
          continue
        }
      }

      // Can our route handle the path?
      let (canHandle, params) = route.canHandle(path: request.uri.path)
      if !canHandle { continue }

      // We found the route, transfer the URI parameters to the request
      matchingRoute = route
      params.forEach { request.params[$0] = $1 }
      break
    }

    // If we found a route then call its handler
    if let route = matchingRoute {
      return try route.handler(request)
    }

    // Otherwise return 404 not found
    return HTTPResponse(.notFound)
  }
}
