//
//  WebSocketErrorHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/23/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol WebSocketErrorHandler {
  func incoming(error: Error, webSocket: WebSocket, message: WebSocketMessage?)
  func outgoing(error: Error, webSocket: WebSocket, message: WebSocketMessage?)
}
