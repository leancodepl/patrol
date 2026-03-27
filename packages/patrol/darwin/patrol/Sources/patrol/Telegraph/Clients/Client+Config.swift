//
//  Client+Config.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/23/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

extension HTTPConfig {
  public static var clientDefault: HTTPConfig {
    return HTTPConfig(requestHandlers: [])
  }
}

extension WebSocketConfig {
  public static var clientDefault: WebSocketConfig {
    var config = WebSocketConfig()
    config.maskMessages = true
    config.pingInterval = 0
    return config
  }
}
