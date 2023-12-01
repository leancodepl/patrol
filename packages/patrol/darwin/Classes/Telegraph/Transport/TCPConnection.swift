//
//  TCPConnection.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/10/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol TCPConnection: AnyObject, Hashable {
  var localEndpoint: Endpoint? { get }
  var remoteEndpoint: Endpoint? { get }

  func open()
  func close(immediately: Bool)
}

// MARK: Hashable implementation

public extension TCPConnection {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }

  func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }
}
