//
//  HTTPVersion.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/31/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct HTTPVersion {
  public let major: UInt
  public let minor: UInt

  public init(major: UInt, minor: UInt) {
    self.major = major
    self.minor = minor
  }
}

public extension HTTPVersion {
  static let `default` = HTTPVersion(major: 1, minor: 1)
}

extension HTTPVersion: CustomStringConvertible {
  public var description: String {
    return "HTTP/\(major).\(minor)"
  }
}
