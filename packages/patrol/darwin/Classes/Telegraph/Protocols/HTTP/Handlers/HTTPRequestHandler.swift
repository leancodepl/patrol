//
//  HTTPRequestHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/19/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol HTTPRequestHandler {
  func respond(to request: HTTPRequest, nextHandler: HTTPRequest.Handler) throws -> HTTPResponse?
}

public extension HTTPRequest {
  typealias Handler = (HTTPRequest) throws -> HTTPResponse?
}

extension Collection where Element == HTTPRequestHandler {
  // Creates a closure chain with all of the handlers
  func chain(lastHandler: @escaping HTTPRequest.Handler = { _ in nil }) -> HTTPRequest.Handler {
    return reversed().reduce(lastHandler) { nextHandler, handler in
      return { request in try handler.respond(to: request, nextHandler: nextHandler) }
    }
  }
}
