//
//  WebSocketMessageHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/23/17.
//  Copyright © 2017 Building42. All rights reserved.
//

public protocol WebSocketMessageHandler {
  func incoming(message: WebSocketMessage, from webSocket: WebSocket) throws
  func outgoing(message: WebSocketMessage, to webSocket: WebSocket) throws
}
