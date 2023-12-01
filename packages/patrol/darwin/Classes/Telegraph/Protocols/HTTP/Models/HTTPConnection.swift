//
//  HTTPConnection.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/2/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

// MARK: HTTPConnectionDelegate

public protocol HTTPConnectionDelegate: AnyObject {
  func connection(_ httpConnection: HTTPConnection, didCloseWithError error: Error?)
  func connection(_ httpConnection: HTTPConnection, handleIncomingRequest request: HTTPRequest, error: Error?)
  func connection(_ httpConnection: HTTPConnection, handleIncomingResponse response: HTTPResponse, error: Error?)
  func connection(_ httpConnection: HTTPConnection, handleUpgradeByRequest request: HTTPRequest)
}

// MARK: HTTPConnection

public class HTTPConnection: TCPConnection {
  public weak var delegate: HTTPConnectionDelegate?

  private let socket: TCPSocket
  private let config: HTTPConfig
  private var parser: HTTPParser
  private var upgrading = false
  private var upgradeData: Data?

  /// Initializes the HTTP connection.
  public required init(socket: TCPSocket, config: HTTPConfig) {
    self.socket = socket
    self.config = config
    self.parser = HTTPParser()
  }

  /// Opens the connection.
  public func open() {
    socket.delegate = self
    socket.read(timeout: config.readTimeout)
  }

  /// Closes the connection.
  public func close(immediately: Bool) {
    socket.close(when: immediately ? .immediately : .afterWriting)
  }

  /// Upgrades the connection.
  public func upgrade() -> (TCPSocket, Data?) {
    upgrading = true
    return (socket, upgradeData)
  }

  /// Sends raw data by writing it to the stream. This can be useful for writing body data over time to a keep-alive connection.
  public func send(data: Data, timeout: TimeInterval) {
    socket.write(data: data, timeout: timeout)
  }

  /// Sends the request by writing it to the stream.
  public func send(request: HTTPRequest) {
    request.prepareForWrite()
    request.write(to: socket, headerTimeout: config.writeHeaderTimeout, bodyTimeout: config.writeBodyTimeout)
  }

  /// Sends the response by writing it to the stream.
  public func send(response: HTTPResponse, toRequest request: HTTPRequest) {
    // Do not write the body for HEAD requests
    if request.method == .HEAD {
      response.stripBody = true
    }

    // Do not keep-alive if the request doesn't want keep-alive
    if request.keepAlive == false {
      response.headers.connection = "close"
    }

    // Prepare and send the response
    response.prepareForWrite()
    response.write(to: socket, headerTimeout: config.writeHeaderTimeout, bodyTimeout: config.writeBodyTimeout)

    // Does the response request a connection upgrade?
    if response.isConnectionUpgrade {
      delegate?.connection(self, handleUpgradeByRequest: request)
      return
    }

    // Close the connection after writing if not keep-alive
    if !response.keepAlive && response.isComplete {
      close(immediately: false)
    }
  }

  /// Handles incoming data.
  private func received(data: Data) {
    do {
      let bytesParsed = try parser.parse(data: data)

      // Do we detect a connection upgrade?
      if parser.isUpgradeDetected {
        upgrading = true

        // The data might have contained data of the new protocol
        if bytesParsed < data.count {
          upgradeData = data.subdata(in: bytesParsed..<data.count)
        }

        // Handle the message, no need to reset, this connection will end
        received(message: parser.message, error: nil)
        return
      }

      // Do we have a complete message?
      if parser.isMessageComplete {
        received(message: parser.message, error: nil)
        parser.reset()
      }

      // Continue reading
      if !upgrading {
        socket.read(timeout: config.readTimeout)
      }
    } catch {
      // If we encounter a parser error, try to handle it gracefully
      received(message: parser.message, error: error)
    }
  }

  /// Handles an incoming HTTP message.
  private func received(message: HTTPMessage?, error: Error?) {
    switch message {
    case let message as HTTPRequest:
      delegate?.connection(self, handleIncomingRequest: message, error: error)
    case let message as HTTPResponse:
      delegate?.connection(self, handleIncomingResponse: message, error: error)
    default:
      close(immediately: true)
    }
  }
}

public extension HTTPConnection {
  /// The local endpoint information of the connection.
  var localEndpoint: Endpoint? {
    return socket.localEndpoint
  }

  /// The remote endpoint information of the connection.
  var remoteEndpoint: Endpoint? {
    return socket.remoteEndpoint
  }
}

// MARK: TCPSocketDelegate implementation

extension HTTPConnection: TCPSocketDelegate {
  /// Raised when the socket is connected (ignore, socket is already connected).
  public func socketDidOpen(_ socket: TCPSocket) {}

  /// Raised when the socket is disconnected.
  public func socketDidClose(_ socket: TCPSocket, error: Error?) {
    delegate?.connection(self, didCloseWithError: error)
  }

  /// Raised when the socket received data.
  public func socketDidRead(_ socket: TCPSocket, data: Data, tag: Int) {
    received(data: data)
  }

  /// Raised when the socket sent data (ignore).
  public func socketDidWrite(_ socket: TCPSocket, tag: Int) {}
}
