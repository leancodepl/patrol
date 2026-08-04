//
//  WebSocketConfig.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/21/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct WebSocketConfig {
  /// The maximum time the connection will wait for incoming data.
  public var readTimeout: TimeInterval = 300

  /// The maximum time the connection will wait for writing header data.
  public var writeHeaderTimeout: TimeInterval = 30

  /// The maximum time the connection will wait for writing payload data.
  public var writePayloadTimeout: TimeInterval = 300

  /// Indicates if messages should be masked before sending (normally only applies to client messages on an unecrypted connection).
  public var maskMessages = true

  /// The interval that ping messages should be send (normally only the server should send ping messages).
  public var pingInterval: TimeInterval = 0

  /// The handler for websocket message errors.
  public var errorHandler: WebSocketErrorHandler = WebSocketErrorDefaultHandler()

  /// The handlers for websocket messages.
  public var messageHandler: WebSocketMessageHandler = WebSocketMessageDefaultHandler()

  public init() {}
}
