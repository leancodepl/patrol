//
//  Data+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/13/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension Data {
  /// The bytes for carriage return, line feed.
  static let crlf = Data([0xD, 0xA])

  /// Creates data with a random set of bytes.
  init(randomNumberOfBytes count: Int) {
    self.init(count: count)
    withUnsafeMutableBytes { _ = SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress!) }
  }

  /// An hexadecimal string representation of the bytes.
  func hexEncodedString() -> String {
    let hexDigits = Array("0123456789abcdef".utf16)
    var hexChars = [UTF16.CodeUnit]()
    hexChars.reserveCapacity(count * 2)

    for byte in self {
      let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
      hexChars.append(hexDigits[index1])
      hexChars.append(hexDigits[index2])
    }

    return String(utf16CodeUnits: hexChars, count: hexChars.count)
  }

  /// Masks the contents of the data with the provided mask bytes.
  mutating func mask(with maskBytes: [UInt8]) {
    let maskSize = maskBytes.count
    for index in 0..<count {
      self[index] ^= maskBytes[index % maskSize]
    }
  }
}
