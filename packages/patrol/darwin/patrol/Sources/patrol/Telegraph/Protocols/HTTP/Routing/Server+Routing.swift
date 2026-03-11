//
//  Server+Routing.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/19/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

extension Server {
  /// Adds a route handler consisting of a HTTP method, uri and handler closure.
  public func route(_ method: HTTPMethod, _ uri: String, _ handler: @escaping HTTPRequest.Handler) {
    guard let httpRoute = try? HTTPRoute(methods: [method], uri: uri, handler: handler) else {
      fatalError("Could not add route - invalid uri: \(uri)")
    }

    route(httpRoute)
  }

  /// Adds a route handler consisting of a HTTP method, uri regex and handler closure.
  public func route(_ method: HTTPMethod, regex: String, _ handler: @escaping HTTPRequest.Handler) {
    guard let httpRoute = try? HTTPRoute(methods: [method], regex: regex, handler: handler) else {
      fatalError("Could not add route - invalid regex: \(regex)")
    }

    route(httpRoute)
  }

  /// Adds a route.
  public func route(_ httpRoute: HTTPRoute) {
    guard let routeHandler = httpConfig.requestHandlers.first(ofType: HTTPRouteHandler.self) else {
      fatalError("Could not add route - the server doesn't have a route handler")
    }

    routeHandler.routes.append(httpRoute)
  }
}

// MARK: Response helper methods

extension Server {
  /// Adds a route that responds to *method* on *uri* that responds with a *response*.
  public func route(_ method: HTTPMethod, _ uri: String, response: @escaping () -> HTTPResponse) {
    route(method, uri) { _ in response() }
  }

  /// Adds a route that responds to *method* on *uri* that responds with a *statusCode*.
  public func route(_ method: HTTPMethod, _ uri: String, status: @escaping () -> HTTPStatus) {
    route(method, uri) { _ in HTTPResponse(status()) }
  }

  /// Adds a route that responds to *method* on *uri* that responds with *statusCode* and text content.
  public func route(
    _ method: HTTPMethod, _ uri: String, content: @escaping () -> (HTTPStatus, String)
  ) {
    route(method, uri) { _ in
      let (status, string) = content()
      return HTTPResponse(status, content: string)
    }
  }
}
