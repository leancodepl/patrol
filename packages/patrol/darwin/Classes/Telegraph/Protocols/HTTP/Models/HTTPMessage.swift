//
//  HTTPMessage.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class HTTPMessage {
  public var version: HTTPVersion
  public var headers: HTTPHeaders
  public var body: Data

  internal var firstLine: String { return "" }
  internal var stripBody = false

  /// Creates a new HTTPMessage.
  public init(version: HTTPVersion = .default, headers: HTTPHeaders = .empty, body: Data = Data()) {
    self.version = version
    self.headers = headers
    self.body = body
  }

  /// Performs last minute changes to the message, just before writing it to the stream.
  open func prepareForWrite() {
    // Set the keep alive connection header
    if headers.connection == nil {
      headers.connection = keepAlive ? "keep-alive" : "close"
    }
  }

  /// Writes the HTTP message to the provided stream.
  public func write(to stream: WriteStream, headerTimeout: TimeInterval, bodyTimeout: TimeInterval) {
    writeHeader(to: stream, timeout: headerTimeout)
    writeBody(to: stream, timeout: bodyTimeout)
    stream.flush()
  }

  /// Writes the first line and headers to the provided stream.
  open func writeHeader(to stream: WriteStream, timeout: TimeInterval) {
    var head = Data()
    head.reserveCapacity(100)

    // Write the first line
    head.append(firstLine.utf8Data)
    head.append(.crlf)

    // Write the headers
    headers.forEach { key, value in
      head.append("\(key): \(value)".utf8Data)
      head.append(.crlf)
    }

    // Signal the end of the headers with another crlf
    head.append(.crlf)

    stream.write(data: head, timeout: timeout)
  }

  /// Writes the body to the provided stream.
  open func writeBody(to stream: WriteStream, timeout: TimeInterval) {
    if !stripBody {
      stream.write(data: body, timeout: timeout)
    }
  }
}

// MARK: Helper methods

public extension HTTPMessage {
  /// Returns a boolean indicating if the connection should be kept open.
  var keepAlive: Bool {
    guard let connection = headers.connection else { return version.minor != 0 }
    return connection.caseInsensitiveCompare("close") != .orderedSame
  }

  /// Returns a boolean indicating if this message carries an instruction to upgrade.
  var isConnectionUpgrade: Bool {
    return headers.connection?.caseInsensitiveCompare("upgrade") == .orderedSame
  }
}
