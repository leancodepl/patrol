//
//  WebSocketError.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/17/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public enum WebSocketError: Error {
  case invalidMessage
  case invalidOpcode
  case invalidPayloadLength
  case payloadIsNotText
  case payloadTooLarge
}

public extension WebSocketError {
  var code: UInt16 {
    switch self {
    case .invalidMessage: return 1002
    case .invalidOpcode: return 1002
    case .invalidPayloadLength: return 1002
    case .payloadIsNotText: return 1007
    case .payloadTooLarge: return 1009
    }
  }
}

extension WebSocketError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .invalidMessage: return "Invalid message"
    case .invalidOpcode: return "Invalid opcode"
    case .invalidPayloadLength: return "Invalid payload length"
    case .payloadTooLarge: return "Payload is too large"
    case .payloadIsNotText: return "Payload is not UTF8 string data"
    }
  }
}

extension WebSocketError: LocalizedError {
  public var errorDescription: String? {
    return description
  }
}
