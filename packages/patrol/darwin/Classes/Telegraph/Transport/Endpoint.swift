//
//  Endpoint.swift
//  Telegraph
//
//  Created by Yvo van Beek on 9/16/18.
//  Copyright © 2018 Building42. All rights reserved.
//

import Foundation

public struct Endpoint: Hashable {
  public typealias Host = String
  public typealias Port = Int

  public var host: Host
  public var port: Port

  /// Creates an Endpoint based on a host and port.
  public init(host: Host, port: Port) {
    self.host = host
    self.port = port
  }
}

public extension Endpoint {
  /// Creates an Endpoint based on an URL.
  init?(url: URL) {
    guard let host = url.host else { return nil }
    let port = url.port ?? url.portBasedOnScheme

    self.init(host: host, port: port)
  }

  /// Creates an Endpoint based on a host and unsigned port.
  init(host: Host, port: UInt16) {
    self.host = host
    self.port = Int(port)
  }
}
