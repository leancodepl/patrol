//
//  HTTPRequest.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/31/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class HTTPRequest: HTTPMessage {
  public typealias Params = [String: String]

  public var method: HTTPMethod
  public var uri: URI
  public var params = Params()

  /// Creates a new HTTPRequest.
  public init(_ method: HTTPMethod = .GET, uri: URI = .root, version: HTTPVersion = .default,
              headers: HTTPHeaders = .empty, body: Data = Data()) {
    self.method = method
    self.uri = uri
    super.init(version: version, headers: headers, body: body)
  }

  override internal var firstLine: String {
    // The first line looks like this: GET / HTTP/1.1
    return "\(method) \(uri) \(version)"
  }

  override open func prepareForWrite() {
    super.prepareForWrite()

    // Write the content length only if we have a body
    headers.contentLength = body.isEmpty ? nil : body.count
  }
}

// MARK: CustomStringConvertible implementation

extension HTTPRequest: CustomStringConvertible {
  public var description: String {
    let typeName = type(of: self)
    return "<\(typeName): \(method) \(uri) \(version), headers: \(headers.count), body: \(body.count)>"
  }
}
