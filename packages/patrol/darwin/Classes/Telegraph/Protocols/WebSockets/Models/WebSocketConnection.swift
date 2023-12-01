//
//  WebSocketConnection.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/8/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

// MARK: WebSocketConnectionDelegate

public protocol WebSocketConnectionDelegate: AnyObject {
  func connection(_ webSocketConnection: WebSocketConnection, didReceiveMessage message: WebSocketMessage)
  func connection(_ webSocketConnection: WebSocketConnection, didSendMessage message: WebSocketMessage)
  func connection(_ webSocketConnection: WebSocketConnection, didCloseWithError error: Error?)
}

// MARK: WebSocketConnection

open class WebSocketConnection: TCPConnection, WebSocket {
  public weak var delegate: WebSocketConnectionDelegate?

  private let socket: TCPSocket
  private let config: WebSocketConfig
  private var parser: WebSocketParser
  private var pingTimer: DispatchTimer?
  private var closing = false

  /// Initializes a new websocket connection.
  public required init(socket: TCPSocket, config: WebSocketConfig) {
    self.socket = socket
    self.config = config
    self.parser = WebSocketParser()
    self.parser.delegate = self

    // Define a ping timer if a ping interval is set
    if config.pingInterval > 0 {
      pingTimer = DispatchTimer(interval: config.pingInterval, queue: .global()) { [weak self] in
        self?.send(message: WebSocketMessage(opcode: .ping))
      }
    }
  }

  /// Opens the connection.
  public func open() {
    open(data: nil)
  }

  /// Opens the connection with an existing chunk of data.
  public func open(data: Data?) {
    socket.delegate = self

    // Start the ping timer
    pingTimer?.start()

    // Is the data relevant?
    if let data = data, !data.isEmpty {
      received(data: data)
    } else {
      socket.read(timeout: config.readTimeout)
    }
  }

  /// Closes the connection.
  public func close(immediately: Bool) {
    // Normal close routine is to send a close message and wait for a close reply
    if !immediately && !closing {
      send(message: WebSocketMessage(closeCode: 1001))
      return
    }

    // Stop the ping timer
    pingTimer?.stop()

    // Close the socket
    socket.close(when: immediately ? .immediately : .afterWriting)
  }

  /// Sends a websocket message
  public func send(message: WebSocketMessage) {
    do {
      // Is this a close handshake? Mark the connection as closing
      if message.opcode == .connectionClose {
        closing = true
      }

      // Pass the message through the handler
      try config.messageHandler.outgoing(message: message, to: self)

      // Send the message
      message.maskBit = config.maskMessages
      message.write(to: socket, headerTimeout: config.writeHeaderTimeout, payloadTimeout: config.writePayloadTimeout)

      delegate?.connection(self, didSendMessage: message)
    } catch {
      config.errorHandler.outgoing(error: error, webSocket: self, message: message)
    }
  }

  /// Handles incoming data on the socket.
  private func received(data: Data) {
    do {
      try parser.parse(data: data)
      socket.read(timeout: config.readTimeout)
    } catch {
      config.errorHandler.incoming(error: error, webSocket: self, message: nil)
    }
  }

  /// Handles an incoming message.
  private func received(message: WebSocketMessage) {
    do {
      // Reset the ping timer
      pingTimer?.start()

      // Inform the delegate of the incoming message
      delegate?.connection(self, didReceiveMessage: message)

      // Pass the message through the handler
      try config.messageHandler.incoming(message: message, from: self)
    } catch {
      config.errorHandler.incoming(error: error, webSocket: self, message: message)
    }
  }
}

public extension WebSocketConnection {
  /// The local endpoint information of the connection.
  var localEndpoint: Endpoint? {
    return socket.localEndpoint
  }

  /// The remote endpoint information of the connection.
  var remoteEndpoint: Endpoint? {
    return socket.remoteEndpoint
  }
}

// MARK: TCPSocketConnectionDelegate implementation

extension WebSocketConnection: TCPSocketDelegate {
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

// MARK: WebSocketParserDelegate implementation

extension WebSocketConnection: WebSocketParserDelegate {
  public func parser(_ parser: WebSocketParser, didCompleteMessage message: WebSocketMessage) {
    received(message: message)
  }
}
