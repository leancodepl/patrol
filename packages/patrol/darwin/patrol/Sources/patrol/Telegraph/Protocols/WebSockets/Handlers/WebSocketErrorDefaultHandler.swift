//
//  WebSocketErrorDefaultHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 3/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public class WebSocketErrorDefaultHandler: WebSocketErrorHandler {
  // See https://tools.ietf.org/html/rfc6455#page-64

  public func incoming(error: Error, webSocket: WebSocket, message: WebSocketMessage?) {
    webSocket.close(immediately: false)
  }

  public func outgoing(error: Error, webSocket: WebSocket, message: WebSocketMessage?) {}
}
