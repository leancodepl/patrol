//
//  Client+Config.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/23/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension HTTPConfig {
  static var clientDefault: HTTPConfig {
    return HTTPConfig(requestHandlers: [])
  }
}

public extension WebSocketConfig {
  static var clientDefault: WebSocketConfig {
    var config = WebSocketConfig()
    config.maskMessages = true
    config.pingInterval = 0
    return config
  }
}
