//
//  WebSocketMessageDefaultHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 3/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public class WebSocketMessageDefaultHandler: WebSocketMessageHandler {
  public func incoming(message: WebSocketMessage, from webSocket: WebSocket) throws {
    switch message.opcode {

    case .connectionClose:
      // The remote wants to close the connection
      webSocket.close(immediately: false)

    case .ping:
      // The remote sent a ping message, we should respond with a pong with the same payload
      webSocket.send(message: WebSocketMessage(opcode: .pong, payload: message.payload))

    case .continuationFrame, .pong, .binaryFrame, .textFrame:
      // No need to handle these opcodes
      break
    }
  }

  public func outgoing(message: WebSocketMessage, to webSocket: WebSocket) throws {}
}
