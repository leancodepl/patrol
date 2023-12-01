//
//  TCPListener.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/17/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public protocol TCPListenerDelegate: AnyObject {
  /// Called when the listener accepts a new incoming socket
  func listener(_ listener: TCPListener, didAcceptSocket socket: TCPSocket)

  /// Called when the listener socket has disconnected
  func listenerDisconnected(_ listener: TCPListener, error: Error?)
}

public final class TCPListener: NSObject {
  /// The delegate to handle listener events.
  public weak var delegate: TCPListenerDelegate?

  /// The interface the listener listens on.
  public let interface: String?

  /// The TLS configuration for secure connections.
  public let tlsConfig: TLSConfig?

  private let listenerPort: UInt16
  private var listenerSocket: GCDAsyncSocket

  /// Creates a listener that listens on the provided port and interface.
  public init(port: Endpoint.Port, interface: String? = nil, tlsConfig: TLSConfig? = nil) {
    self.listenerPort = UInt16(port)
    self.listenerSocket = GCDAsyncSocket()
    self.interface = interface
    self.tlsConfig = tlsConfig

    super.init()
  }

  /// Indicates if the listener is active.
  public var isListening: Bool {
    return listenerSocket.localPort > 0
  }

  /// The port the listener listens on.
  public var port: Endpoint.Port {
    let port = isListening ? listenerSocket.localPort : listenerPort
    return Endpoint.Port(port)
  }

  /// The queue for delegate calls.
  public var queue: DispatchQueue? {
    return listenerSocket.delegateQueue
  }

  /// Starts the listener with a queue to perform the delegate calls on.
  public func start(queue: DispatchQueue) throws {
    listenerSocket.setDelegate(self, delegateQueue: queue)
    try listenerSocket.accept(onInterface: interface, port: listenerPort)
  }

  /// Stops the listener.
  public func stop() {
    listenerSocket.disconnect()
  }
}

// MARK: GCDAsyncSocketDelegate implementation

extension TCPListener: GCDAsyncSocketDelegate {
  /// Raised when the socket accepts a new incoming client socket.
  public func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    let socket = TCPSocket(wrapping: newSocket)

    // Is this a secure connection?
    if let tlsConfig = tlsConfig {
      socket.startTLS(config: tlsConfig)
    }

    delegate?.listener(self, didAcceptSocket: socket)
  }

  /// Raised when the socket disconnects.
  public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    delegate?.listenerDisconnected(self, error: err)
  }
}
