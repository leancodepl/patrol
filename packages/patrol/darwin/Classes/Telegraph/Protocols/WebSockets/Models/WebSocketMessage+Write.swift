//
//  WebSocket+Write.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/21/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension WebSocketMessage {
  func write(to stream: WriteStream, headerTimeout: TimeInterval, payloadTimeout: TimeInterval) {
    var header = Data()

    // Gather information
    var payloadData = payload.data
    let payloadLength = payloadData?.count ?? 0
    let hasPayload = payloadLength > 0

    // Byte 1: FIN bit + Opcode
    let firstByte = finBit ? WebSocketMasks.finBit : 0
    header.append(firstByte | opcode.rawValue)

    // Byte 2: Mask bit + Payload length
    let secondByte = maskBit ? WebSocketMasks.maskBit : 0
    switch payloadLength {

    // Small payload: [L]
    case 0..<126:
      header.append(secondByte | UInt8(payloadLength))

    // Medium payload: [126][L][L]
    case 126...Int(UInt16.max):
      let sizeBytes = UInt16(payloadLength).bytes
      header.append(secondByte | 126)
      header.append(sizeBytes[0])
      header.append(sizeBytes[1])

    // Large payload: [127][L][L][L][L][L][L][L][L]
    default:
      let sizeBytes = UInt64(payloadLength).bytes
      header.append(secondByte | 127)
      header.append(contentsOf: sizeBytes)
    }

    // Masking key
    if maskBit {
      let maskingKey = generateMask()
      payloadData?.mask(with: maskingKey)
      header.append(contentsOf: maskingKey)
    }

    // Write the header
    stream.write(data: header, timeout: headerTimeout)

    // Write the payload
    if hasPayload, let payloadData = payloadData {
      stream.write(data: payloadData, timeout: payloadTimeout)
    }

    stream.flush()
  }
}

// MARK: WebSocketPayload data conversion

public extension WebSocketPayload {
  var data: Data? {
    switch self {
    case .binary(let data):
      return data
    case .text(let text):
      return text.utf8Data
    case .close(let code, let reason):
      var result = Data()
      result.append(code.bytes[0])
      result.append(code.bytes[1])
      result.append(reason.utf8Data)
      return result
    case .none:
      return nil
    }
  }
}
