//
//  SHA1.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/13/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation
import CommonCrypto

public struct SHA1 {
  /// The message digest.
  public let digest: Data

  /// Creates a SHA1 digest of the provided data.
  public init(data: Data) {
    var buffer = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes { _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &buffer) }

    self.digest = Data(buffer)
  }
}

public extension SHA1 {
  /// Hashes the provided data using the SHA1 algorithm and returns the digest.
  static func hash(_ data: Data) -> Data {
    return SHA1(data: data).digest
  }

  /// Hashes the provided string using the SHA1 algorithm and returns the digest.
  static func hash(_ string: String) -> Data {
    return SHA1(data: string.utf8Data).digest
  }
}
