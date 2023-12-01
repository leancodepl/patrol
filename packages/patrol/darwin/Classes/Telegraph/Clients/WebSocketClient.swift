//
//  WebSocketClient.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/9/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol WebSocketClientDelegate: AnyObject {
  func webSocketClient(_ client: WebSocketClient, didConnectToHost host: String)
  func webSocketClient(_ client: WebSocketClient, didDisconnectWithError error: Error?)

  func webSocketClient(_ client: WebSocketClient, didReceiveData data: Data)
  func webSocketClient(_ client: WebSocketClient, didReceiveText text: String)
}

open class WebSocketClient: WebSocket {
  public let url: URL
  public var headers: HTTPHeaders

  public var config = WebSocketConfig.clientDefault
  public var tlsPolicy: TLSPolicy?
  public weak var delegate: WebSocketClientDelegate?

  private let workQueue = DispatchQueue(label: "Telegraph.WebSocketClient.work")
  private let delegateQueue = DispatchQueue(label: "Telegraph.WebSocketClient.delegate")

  private let endpoint: Endpoint
  private var socket: TCPSocket?
  private var httpConnection: HTTPConnection?
  private var webSocketConnection: WebSocketConnection?

  /// Initializes a new WebSocketClient with an url
  public init(url: URL, headers: HTTPHeaders = .empty) throws {
    guard url.hasWebSocketScheme else { throw WebSocketClientError.invalidScheme }
    guard let endpoint = Endpoint(url: url) else { throw WebSocketClientError.invalidHost }

    // Store the connection information
    self.url = url
    self.endpoint = endpoint
    self.headers = headers

    // Only mask unsecure connections
    config.maskMessages = !url.isSchemeSecure
  }

  /// Performs the handshake with the host, forming the websocket connection.
  public func connect(timeout: TimeInterval = 10) {
    workQueue.async { [weak self] in
      guard let self = self else { return }

      // Release the old connections
      self.httpConnection = nil
      self.webSocketConnection = nil

      // Create and connect the socket
      self.socket = TCPSocket(endpoint: self.endpoint, tlsPolicy: self.tlsPolicy)
      self.socket!.setDelegate(self, queue: self.workQueue)
      self.socket!.connect(timeout: timeout)
    }
  }

  /// Disconnects the client. Same as calling close with immediately: false.
  public func disconnect() {
    close(immediately: false)
  }

  /// Disconnects the client.
  public func close(immediately: Bool) {
    workQueue.async { [weak self] in
      self?.socket?.close(when: .immediately)
      self?.httpConnection?.close(immediately: true)
      self?.webSocketConnection?.close(immediately: immediately)
    }
  }

  /// Sends a raw websocket message.
  public func send(message: WebSocketMessage) {
    workQueue.async { [weak self] in
      self?.webSocketConnection?.send(message: message)
    }
  }

  /// Performs a handshake to initiate the websocket connection.
  private func performHandshake(socket: TCPSocket) {
    // Create the handshake request
    let requestURI = URI(path: url.path, query: url.query)
    let handshakeRequest = HTTPRequest(uri: requestURI, headers: headers)
    handshakeRequest.webSocketHandshake(host: endpoint.host, port: endpoint.port)

    // Create the HTTP connection (retains the socket)
    self.httpConnection = HTTPConnection(socket: socket, config: HTTPConfig.clientDefault)
    self.httpConnection!.delegate = self
    self.httpConnection!.open()

    // Send the handshake request
    self.httpConnection!.send(request: handshakeRequest)
  }

  /// Processes the handshake response.
  private func handleHandshakeResponse(_ response: HTTPResponse) {
    // Validate the handshake response
    guard response.isWebSocketHandshake else {
      let handShakeError = WebSocketClientError.handshakeFailed(response: response)
      handleHandshakeError(handShakeError)
      return
    }

    // Extract the information from the HTTP connection
    guard let (socket, webSocketData) = httpConnection?.upgrade() else { return }

    // Release the HTTP connection
    httpConnection = nil

    // Create a WebSocket connection (retains the socket)
    webSocketConnection = WebSocketConnection(socket: socket, config: config)
    webSocketConnection!.delegate = self
    webSocketConnection!.open(data: webSocketData)

    // Inform the delegate that we are connected
    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      self.delegate?.webSocketClient(self, didConnectToHost: self.endpoint.host)
    }
  }

  /// Handles a bad response on the websocket handshake.
  private func handleHandshakeError(_ error: Error?) {
    // Prevent any connection delegate calls, we want to provide our own error
    httpConnection?.delegate = nil
    webSocketConnection?.delegate = nil

    // Manually close and report the error
    close(immediately: true)
    handleConnectionClose(error: error)
  }

  /// Handles a connection close.
  private func handleConnectionClose(error: Error?) {
    httpConnection = nil
    webSocketConnection = nil

    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      self.delegate?.webSocketClient(self, didDisconnectWithError: error)
    }
  }
}

// MARK: WebSocket conformance

public extension WebSocketClient {
  /// The local endpoint information, only available when connected.
  var localEndpoint: Endpoint? {
    return socket?.localEndpoint
  }

  /// The remote endpoint information, only available when connected.
  var remoteEndpoint: Endpoint? {
    return socket?.remoteEndpoint
  }
}

// MARK: Convenience initializers

public extension WebSocketClient {
  /// Creates a new WebSocketClient with an url in string form.
  convenience init(_ string: String) throws {
    guard let url = URL(string: string) else { throw WebSocketClientError.invalidURL }
    try self.init(url: url)
  }

  /// Creates a new WebSocketClient with an url in string form and certificates to trust.
  convenience init(_ string: String, certificates: [Certificate]) throws {
    try self.init(string)
    self.tlsPolicy = TLSPolicy(certificates: certificates)
  }

  /// Creates a new WebSocketClient with an url and certificates to trust.
  convenience init(url: URL, certificates: [Certificate]) throws {
    try self.init(url: url)
    self.tlsPolicy = TLSPolicy(certificates: certificates)
  }
}

// MARK: TCPSocketDelegate implementation

extension WebSocketClient: TCPSocketDelegate {
  /// Raised when the socket has connected.
  public func socketDidOpen(_ socket: TCPSocket) {
    guard socket == self.socket else { return }

    // Stop retaining the socket
    self.socket = nil

    // Start TLS for secure hosts
    if url.isSchemeSecure {
      socket.startTLS()
    }

    // Send the handshake request
    performHandshake(socket: socket)
  }

  /// Raised when the socket disconnected.
  public func socketDidClose(_ socket: TCPSocket, error: Error?) {
    guard socket == self.socket else { return }
    handleConnectionClose(error: error)
  }

  /// Raised when the socket reads (ignore, the connections will handle this).
  public func socketDidRead(_ socket: TCPSocket, data: Data, tag: Int) {}

  /// Raised when the socket writes (ignore).
  public func socketDidWrite(_ socket: TCPSocket, tag: Int) {}
}

// MARK: TCPSocketDelegate implementation

extension WebSocketClient: HTTPConnectionDelegate {
  /// Raised when the HTTPConnecion was closed.
  public func connection(_ httpConnection: HTTPConnection, didCloseWithError error: Error?) {
    guard httpConnection == self.httpConnection else { return }
    handleConnectionClose(error: error)
  }

  /// Raised when the HTTPConnecion received a response.
  public func connection(_ httpConnection: HTTPConnection, handleIncomingResponse response: HTTPResponse, error: Error?) {
    guard httpConnection == self.httpConnection else { return }

    if let error = error {
      handleHandshakeError(error)
    } else {
      handleHandshakeResponse(response)
    }
  }

  /// Raised when the HTTPConnecion received a request (client doesn't support requests -> close).
  public func connection(_ httpConnection: HTTPConnection, handleIncomingRequest request: HTTPRequest, error: Error?) {
    guard httpConnection == self.httpConnection else { return }
    httpConnection.close(immediately: true)
  }

  /// Raised when the HTTPConnecion received a request (client doesn't support request upgrades -> close).
  public func connection(_ httpConnection: HTTPConnection, handleUpgradeByRequest request: HTTPRequest) {
    guard httpConnection == self.httpConnection else { return }
    httpConnection.close(immediately: true)
  }
}

// MARK: WebSocketConnectionDelegate implementation

extension WebSocketClient: WebSocketConnectionDelegate {
  /// Raised when the WebSocketConnection disconnected.
  public func connection(_ webSocketConnection: WebSocketConnection, didCloseWithError error: Error?) {
    guard webSocketConnection == self.webSocketConnection else { return }
    handleConnectionClose(error: error)
  }

  /// Raised when the WebSocketConnection receives a message.
  public func connection(_ webSocketConnection: WebSocketConnection, didReceiveMessage message: WebSocketMessage) {
    guard webSocketConnection == self.webSocketConnection else { return }

    // We are only interested in binary and text messages
    guard message.opcode == .binaryFrame || message.opcode == .textFrame else { return }

    // Inform the delegate
    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      switch message.payload {
      case let .binary(data): self.delegate?.webSocketClient(self, didReceiveData: data)
      case let .text(text): self.delegate?.webSocketClient(self, didReceiveText: text)
      default: break
      }
    }
  }

  /// Raised when the WebSocketConnection sent a message (ignore).
  public func connection(_ webSocketConnection: WebSocketConnection, didSendMessage message: WebSocketMessage) {}
}
