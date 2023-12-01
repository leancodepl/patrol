//
//  HTTPMethod.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//

public struct HTTPMethod: Hashable {
  public let name: String
}

public extension HTTPMethod {
  static let GET = HTTPMethod(name: "GET")
  static let HEAD = HTTPMethod(name: "HEAD")
  static let DELETE = HTTPMethod(name: "DELETE")
  static let POST = HTTPMethod(name: "POST")
  static let PUT = HTTPMethod(name: "PUT")
  static let OPTIONS = HTTPMethod(name: "OPTIONS")
  static let CONNECT = HTTPMethod(name: "CONNECT")
  static let TRACE = HTTPMethod(name: "TRACE")
  static let PATCH = HTTPMethod(name: "PATCH")
}

// MARK: CustomStringConvertible implementation

extension HTTPMethod: CustomStringConvertible {
  public var description: String {
    return name
  }
}

// MARK: ExpressibleByStringLiteral implementation

extension HTTPMethod: ExpressibleByStringLiteral {
  public init(stringLiteral string: String) {
    self.init(name: string)
  }
}
