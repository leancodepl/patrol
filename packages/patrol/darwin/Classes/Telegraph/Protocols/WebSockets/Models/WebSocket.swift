//
//  WebSocket.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/23/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol WebSocket: AnyObject {
  var localEndpoint: Endpoint? { get }
  var remoteEndpoint: Endpoint? { get }

  func close(immediately: Bool)
  func send(data: Data)
  func send(text: String)
  func send(message: WebSocketMessage)
}

// MARK: Default implementation

public extension WebSocket {
  func send(data: Data) {
    send(message: WebSocketMessage(data: data))
  }

  func send(text: String) {
    send(message: WebSocketMessage(text: text))
  }
}
