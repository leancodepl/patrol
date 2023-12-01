//
//  Server+Config.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/23/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension HTTPConfig {
  static var serverDefault: HTTPConfig {
    return HTTPConfig(requestHandlers: [HTTPWebSocketHandler(), HTTPRouteHandler()])
  }
}

public extension WebSocketConfig {
  static var serverDefault: WebSocketConfig {
    var config = WebSocketConfig()
    config.maskMessages = false
    config.pingInterval = 60
    return config
  }
}
