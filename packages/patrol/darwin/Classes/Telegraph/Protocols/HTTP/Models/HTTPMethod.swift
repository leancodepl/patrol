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

extension HTTPMethod {
  public static let GET = HTTPMethod(name: "GET")
  public static let HEAD = HTTPMethod(name: "HEAD")
  public static let DELETE = HTTPMethod(name: "DELETE")
  public static let POST = HTTPMethod(name: "POST")
  public static let PUT = HTTPMethod(name: "PUT")
  public static let OPTIONS = HTTPMethod(name: "OPTIONS")
  public static let CONNECT = HTTPMethod(name: "CONNECT")
  public static let TRACE = HTTPMethod(name: "TRACE")
  public static let PATCH = HTTPMethod(name: "PATCH")
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
