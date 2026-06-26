//
//  HTTPHeader+WebSocket.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/9/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

extension HTTPHeaderName {
  public static let webSocketAccept = HTTPHeaderName("Sec-WebSocket-Accept")
  public static let webSocketKey = HTTPHeaderName("Sec-WebSocket-Key")
  public static let webSocketProtocol = HTTPHeaderName("Sec-WebSocket-Protocol")
  public static let webSocketVersion = HTTPHeaderName("Sec-WebSocket-Version")
}

extension Dictionary where Key == HTTPHeaderName, Value == String {
  public var webSocketAccept: String? {
    get { return self[.webSocketAccept] }
    set { self[.webSocketAccept] = newValue }
  }

  public var webSocketKey: String? {
    get { return self[.webSocketKey] }
    set { self[.webSocketKey] = newValue }
  }

  public var webSocketProtocol: String? {
    get { return self[.webSocketProtocol] }
    set { self[.webSocketProtocol] = newValue }
  }

  public var webSocketVersion: String? {
    get { return self[.webSocketVersion] }
    set { self[.webSocketVersion] = newValue }
  }
}
