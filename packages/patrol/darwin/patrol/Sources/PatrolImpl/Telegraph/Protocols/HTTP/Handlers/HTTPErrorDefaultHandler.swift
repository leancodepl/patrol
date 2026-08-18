//
//  HTTPErrorDefaultHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 3/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public class HTTPErrorDefaultHandler: HTTPErrorHandler {
  public func respond(to error: Error) -> HTTPResponse? {
    switch error {
    // Stream errors, we should disconnect
    case HTTPError.unexpectedStreamEnd, HTTPError.connectionShouldBeClosed:
      return nil

    // Protocol errors
    case HTTPError.protocolNotSupported:
      return HTTPResponse(.notImplemented, error: error)

    // Request errors
    case HTTPError.invalidMethod:
      return HTTPResponse(.methodNotAllowed, error: error)
    case HTTPError.invalidVersion:
      return HTTPResponse(.httpVersionNotSupported, error: error)
    case HTTPError.headerOverflow:
      return HTTPResponse(.requestHeaderFieldsTooLarge, error: error)
    case is HTTPError:
      return HTTPResponse(.badRequest, error: error)

    // Other unknown errors
    default:
      return HTTPResponse(error: error)
    }
  }
}
