//
//  HTTPConfig.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/20/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct HTTPConfig {
  /// The maximum time the connection will wait for incoming data.
  public var readTimeout: TimeInterval = 60

  /// The maximum time the connection will wait for writing header data.
  public var writeHeaderTimeout: TimeInterval = 30

  /// The maximum time the connection will wait for writing body data.
  public var writeBodyTimeout: TimeInterval = 300

  /// The handler that will create a response for an error during a request.
  public var errorHandler: HTTPErrorHandler = HTTPErrorDefaultHandler()

  /// The handlers that will create a response for a request.
  public var requestHandlers: [HTTPRequestHandler] {
    didSet { requestChain = requestHandlers.chain() }
  }

  /// A closure that joins together the request handlers.
  internal private(set) var requestChain: HTTPRequest.Handler

  /// Initializes a new HTTPConfig.
  public init(requestHandlers: [HTTPRequestHandler]) {
    self.requestHandlers = requestHandlers
    self.requestChain = requestHandlers.chain()
  }
}
