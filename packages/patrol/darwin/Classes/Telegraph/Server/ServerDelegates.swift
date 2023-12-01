//
//  ServerDelegates.swift
//  Telegraph
//
//  Created by Yvo van Beek on 4/5/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol ServerDelegate: AnyObject {
  /// Called when the server has stopped
  func serverDidStop(_ server: Server, error: Error?)
}

public protocol ServerWebSocketDelegate: AnyObject {
  /// Called when a web socket connected
  func server(_ server: Server, webSocketDidConnect webSocket: WebSocket, handshake: HTTPRequest)

  /// Called when a web socket disconnected
  func server(_ server: Server, webSocketDidDisconnect webSocket: WebSocket, error: Error?)

  /// Called when a message was received from a web socket
  func server(_ server: Server, webSocket: WebSocket, didReceiveMessage message: WebSocketMessage)

  /// Called when a message was sent to a web socket
  func server(_ server: Server, webSocket: WebSocket, didSendMessage message: WebSocketMessage)

  /// Deprecated: use ServerDelegate - serverDidStop
  func serverDidDisconnect(_ server: Server)
}

// MARK: Default implementation

public extension ServerWebSocketDelegate {
  func server(_ server: Server, webSocket: WebSocket, didSendMessage message: WebSocketMessage) {}
  func serverDidDisconnect(_ server: Server) {}
}
