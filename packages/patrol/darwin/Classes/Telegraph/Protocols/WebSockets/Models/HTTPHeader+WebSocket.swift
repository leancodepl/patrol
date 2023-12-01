//
//  HTTPHeader+WebSocket.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/9/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension HTTPHeaderName {
  static let webSocketAccept = HTTPHeaderName("Sec-WebSocket-Accept")
  static let webSocketKey = HTTPHeaderName("Sec-WebSocket-Key")
  static let webSocketProtocol = HTTPHeaderName("Sec-WebSocket-Protocol")
  static let webSocketVersion = HTTPHeaderName("Sec-WebSocket-Version")
}

public extension Dictionary where Key == HTTPHeaderName, Value == String {
  var webSocketAccept: String? {
    get { return self[.webSocketAccept] }
    set { self[.webSocketAccept] = newValue }
  }

  var webSocketKey: String? {
    get { return self[.webSocketKey] }
    set { self[.webSocketKey] = newValue }
  }

  var webSocketProtocol: String? {
    get { return self[.webSocketProtocol] }
    set { self[.webSocketProtocol] = newValue }
  }

  var webSocketVersion: String? {
    get { return self[.webSocketVersion] }
    set { self[.webSocketVersion] = newValue }
  }
}
