//
//  HTTPHeader.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/8/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [HTTPHeaderName: String]

public struct HTTPHeaderName: Hashable {
  private let name: String
  private let nameInLowercase: String

  /// Creates a HTTPHeader name. Header names are case insensitive according to RFC7230.
  init(_ name: String) {
    self.name = name
    self.nameInLowercase = name.lowercased()
  }

  /// Returns a Boolean value indicating whether two names are equal.
  public static func == (lhs: HTTPHeaderName, rhs: HTTPHeaderName) -> Bool {
    return lhs.nameInLowercase == rhs.nameInLowercase
  }

  /// Hashes the name by feeding it into the given hasher.
  public func hash(into hasher: inout Hasher) {
    nameInLowercase.hash(into: &hasher)
  }
}

// MARK: CustomStringConvertible implementation

extension HTTPHeaderName: CustomStringConvertible {
  public var description: String {
    return name
  }
}

// MARK: ExpressibleByStringLiteral implementation

extension HTTPHeaderName: ExpressibleByStringLiteral {
  public init(stringLiteral string: String) {
    self.init(string)
  }
}

// MARK: Convenience methods

public extension Dictionary where Key == HTTPHeaderName, Value == String {
  static var empty: HTTPHeaders {
    return self.init(minimumCapacity: 3)
  }

  subscript(key: String) -> String? {
    get { return self[HTTPHeaderName(key)] }
    set { self[HTTPHeaderName(key)] = newValue }
  }
}
