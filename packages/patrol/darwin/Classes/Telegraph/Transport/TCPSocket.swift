//
//  TCPSocket.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/2/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

// MARK: TCPSocketClose

public enum TCPSocketClose {
  case immediately
  case afterReading
  case afterWriting
  case afterReadingAndWriting
}

// MARK: TCPSocketDelegate

public protocol TCPSocketDelegate: AnyObject {
  func socketDidOpen(_ socket: TCPSocket)
  func socketDidClose(_ socket: TCPSocket, error: Error?)
  func socketDidRead(_ socket: TCPSocket, data: Data, tag: Int)
  func socketDidWrite(_ socket: TCPSocket, tag: Int)
}

// MARK: TCPSocket

public final class TCPSocket: NSObject {
  /// The endpoint to connect to.
  public let endpoint: Endpoint

  /// The delegate to handle socket events.
  public weak var delegate: TCPSocketDelegate?

  private let socket: GCDAsyncSocket
  private let tlsPolicy: TLSPolicy?

  /// Creates a socket to connect to an endpoint.
  public init(endpoint: Endpoint, tlsPolicy: TLSPolicy? = nil) {
    self.endpoint = endpoint
    self.tlsPolicy = tlsPolicy
    self.socket = GCDAsyncSocket()

    defer { socket.delegate = self }
    super.init()
  }

  /// Creates a socket by wrapping an existing GCDAsyncSocket.
  internal init(wrapping socket: GCDAsyncSocket) {
    self.endpoint = Endpoint(host: socket.localHost ?? "", port: socket.localPort)
    self.tlsPolicy = nil
    self.socket = socket

    defer { socket.delegate = self }
    super.init()
  }

  /// Indicates if the socket is connected.
  public var isConnected: Bool {
    return socket.isConnected
  }

  /// The local endpoint information, only available when connected.
  public var localEndpoint: Endpoint? {
    guard let host = socket.localHost else { return nil }
    return Endpoint(host: host, port: socket.localPort)
  }

  /// The remote endpoint information, only available when connected.
  public var remoteEndpoint: Endpoint? {
    guard let host = socket.connectedHost else { return nil }
    return Endpoint(host: host, port: socket.connectedPort)
  }

  /// The queue for delegate calls.
  public var queue: DispatchQueue? {
    return socket.delegateQueue
  }

  /// Sets the delegate that will receive delegate calls on the provided queue.
  public func setDelegate(_ delegate: TCPSocketDelegate, queue: DispatchQueue) {
    self.delegate = delegate
    socket.setDelegate(self, delegateQueue: queue)
  }

  /// Sets the queue to perform the delegate calls on.
  public func setDelegateQueue(_ queue: DispatchQueue) {
    socket.setDelegate(self, delegateQueue: queue)
  }

  /// Opens the connection, calls the delegate if it succeeds / fails.
  public func connect(timeout: TimeInterval = 30) {
    do {
      try socket.connect(toHost: endpoint.host, onPort: UInt16(endpoint.port), withTimeout: timeout)
    } catch {
      delegate?.socketDidClose(self, error: error)
    }
  }

  /// Closes the connection.
  public func close(when: TCPSocketClose = .immediately) {
    switch when {
    case .immediately: socket.disconnect()
    case .afterReading: socket.disconnectAfterReading()
    case .afterWriting: socket.disconnectAfterWriting()
    case .afterReadingAndWriting: socket.disconnectAfterReadingAndWriting()
    }
  }

  /// Reads data with a timeout and tag.
  public func read(timeout: TimeInterval = -1, tag: Int = 0) {
    socket.readData(withTimeout: timeout, tag: tag)
  }

  /// Reads data with a max length, timeout and tag.
  public func read(maxLength: Int, timeout: TimeInterval = -1, tag: Int = 0) {
    socket.readData(toLength: UInt(maxLength), withTimeout: timeout, tag: tag)
  }

  /// Writes data with a timeout and tag.
  public func write(data: Data, timeout: TimeInterval = -1, tag: Int = 0) {
    socket.write(data, withTimeout: timeout, tag: tag)
  }

  /// Starts the TLS handshake for secure connections.
  public func startTLS(config: TLSConfig = TLSConfig()) {
    var rawConfig = config.rawConfig

    // When a TLS policy is set, enable manual trust evaluation
    if tlsPolicy != nil {
      rawConfig[GCDAsyncSocketManuallyEvaluateTrust] = true as CFBoolean
    }

    socket.startTLS(rawConfig)
  }
}

/// ReadStream and WriteStream implementation

extension TCPSocket: ReadStream, WriteStream {
  /// Reads data with a timeout and tag.
  public func read(timeout: TimeInterval) {
    read(timeout: timeout, tag: 0)
  }

  /// Writes data with a timeout and tag.
  public func write(data: Data, timeout: TimeInterval) {
    write(data: data, timeout: timeout, tag: 0)
  }

  /// Flushes any open writes.
  public func flush() {}
}

// MARK: GCDAsyncSocketDelegate implementation

extension TCPSocket: GCDAsyncSocketDelegate {
  /// Raised when the socket has connected to the host.
  public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    delegate?.socketDidOpen(self)
  }

  /// Raised when the socket has disconnected from the host.
  public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    delegate?.socketDidClose(self, error: err)
  }

  /// Raised when the socket is done reading data.
  public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    delegate?.socketDidRead(self, data: data, tag: tag)
  }

  /// Raised when the socket is done writing data.
  public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
    delegate?.socketDidWrite(self, tag: tag)
  }

  /// Raised when the socket is asking to evaluate the trust as part of the TLS handshake.
  public func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
    let trusted = tlsPolicy?.evaluate(trust: trust) ?? false
    completionHandler(trusted)
  }
}
