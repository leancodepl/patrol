//
//  WebSocketMessage.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/17/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class WebSocketMessage {
  public var finBit = true
  public var maskBit = true
  public var opcode: WebSocketOpcode
  public var payload: WebSocketPayload

  /// Creates a WebSocketMessage.
  public init(opcode: WebSocketOpcode = .connectionClose, payload: WebSocketPayload = .none) {
    self.opcode = opcode
    self.payload = payload
  }
}

public enum WebSocketOpcode: UInt8 {
  case continuationFrame = 0x0
  case textFrame = 0x1
  case binaryFrame = 0x2
  case connectionClose = 0x8
  case ping = 0x9
  case pong = 0xA
}

public enum WebSocketPayload {
  case none
  case binary(Data)
  case text(String)
  case close(code: UInt16, reason: String)
}

public struct WebSocketMasks {
  static let finBit: UInt8 = 0b10000000
  static let opcode: UInt8 = 0b00001111
  static let maskBit: UInt8 = 0b10000000
  static let payloadLength: UInt8 = 0b01111111
}

// MARK: Convenience initializers

public extension WebSocketMessage {
  /// Creates a WebSocketMessage that instructs to close the connection.
  convenience init(closeCode: UInt16, reason: String = "") {
    self.init(opcode: .connectionClose, payload: .close(code: closeCode, reason: reason))
  }

  /// Creates a WebSocketMessage that reports an error and closes the connection.
  convenience init(error: WebSocketError) {
    self.init(closeCode: error.code, reason: error.description)
  }

  /// Creates a WebSocketMessage with a binary payload.
  convenience init(data: Data) {
    self.init(opcode: .binaryFrame, payload: .binary(data))
  }

  /// Creates a WebSocketMessage with a text payload.
  convenience init(text: String) {
    self.init(opcode: .textFrame, payload: .text(text))
  }
}

// MARK: Masking

public extension WebSocketMessage {
  func generateMask() -> [UInt8] {
    return [UInt8.random, UInt8.random, UInt8.random, UInt8.random]
  }
}

// MARK: CustomStringConvertible

extension WebSocketMessage: CustomStringConvertible {
  public var description: String {
    let typeName = type(of: self)
    var info = "<\(typeName): opcode: \(opcode), payload: "

    switch payload {
    case .binary(let data):
      info += "\(data.count) bytes>"
    case .text(let text):
      info += "'\(text.truncate(count: 50, ellipses: true))'>"
    case .close(let code, _):
      info += "close \(code)>"
    case .none:
      info += "none>"
    }

    return info
  }
}
