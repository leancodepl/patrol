//
//  Server.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/20/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class Server {
  public weak var delegate: ServerDelegate?
  public var delegateQueue = DispatchQueue(label: "Telegraph.Server.delegate")

  public var httpConfig = HTTPConfig.serverDefault
  public var webSocketConfig = WebSocketConfig.serverDefault
  public weak var webSocketDelegate: ServerWebSocketDelegate?

  private var listener: TCPListener?
  private var tlsConfig: TLSConfig?
  private var httpConnectionSet = SynchronizedSet<HTTPConnection>()
  private var webSocketConnectionSet = SynchronizedSet<WebSocketConnection>()

  private let listenerQueue = DispatchQueue(label: "Telegraph.Server.listener")
  private let connectionsQueue = DispatchQueue(label: "Telegraph.Server.connections")
  private let workerQueue = OperationQueue()

  /// Initializes a unsecure Server instance.
  public init() {}

  /// Initializes a secure Server instance.
  public init(identity: CertificateIdentity, caCertificates: [Certificate]) {
    tlsConfig = TLSConfig(serverIdentity: identity, caCertificates: caCertificates)
  }

  /// Starts the server on the specified port or 0 for automatic port assignment.
  open func start(port: Endpoint.Port = 0, interface: String? = nil) throws {
    listener = TCPListener(port: port, interface: interface, tlsConfig: tlsConfig)
    listener!.delegate = self

    try listener!.start(queue: listenerQueue)
  }

  /// Stops the server, optionally we wait for requests to finish.
  open func stop(immediately: Bool = false) {
    listener?.stop()

    // Close the connections
    httpConnectionSet.forEach { $0.close(immediately: immediately) }
    webSocketConnectionSet.forEach { $0.close(immediately: immediately) }
  }

  /// Handles an incoming socket. The Server normally wraps the socket into a HTTP connection and starts parsing requests.
  open func handleIncoming(socket: TCPSocket) {
    // Configure the socket
    socket.setDelegateQueue(connectionsQueue)

    // Wrap the socket in a HTTP connection
    let httpConnection = HTTPConnection(socket: socket, config: httpConfig)
    httpConnectionSet.insert(httpConnection)

    // Open the HTTP connection
    httpConnection.delegate = self
    httpConnection.open()
  }

  /// Handles an incoming request from the HTTP connection. The Server normally offloads the request to a worker queue to allow concurrent requests.
  open func handleIncoming(request: HTTPRequest, connection: HTTPConnection, error: Error?) {
    workerQueue.addOperation { [weak self, weak connection] in
      guard let self = self, let connection = connection else { return }

      // Get a response for the request
      let response = self.responseFor(request: request, error: error)

      // Send the response or close the connection
      self.connectionsQueue.async {
        if let response = response {
          connection.send(response: response, toRequest: request)
        } else {
          connection.close(immediately: true)
        }
      }
    }
  }

  /// Handles the upgrade of an HTTP request. The Server normally supports the upgrade of an HTTP connection to a WebSocket connection.
  open func handleUpgrade(request: HTTPRequest, connection: HTTPConnection) {
    // We can only handle the WebSocket protocol
    guard request.isWebSocketUpgrade else {
      connection.close(immediately: true)
      return
    }

    // Remove the http connection
    httpConnectionSet.remove(connection)

    // Extract the socket and any WebSocket data already read
    let (socket, webSocketData) = connection.upgrade()

    // Add the websocket connection
    let webSocketConnection = WebSocketConnection(socket: socket, config: webSocketConfig)
    webSocketConnectionSet.insert(webSocketConnection)

    // Open the websocket connection
    webSocketConnection.delegate = self
    webSocketConnection.open(data: webSocketData)

    // Call the delegate
    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      self.webSocketDelegate?.server(self, webSocketDidConnect: webSocketConnection, handshake: request)
    }
  }

  /// Creates a reponse to an HTTP request. If an error occurs, it will call respondTo(error:).
  open func responseFor(request: HTTPRequest) throws -> HTTPResponse? {
    // Put the request through the chain of handlers
    let response = try httpConfig.requestChain(request)

    // Check that a possible connection upgrade was handled properly
    if let response = response, response.status != .switchingProtocols, request.isConnectionUpgrade {
      throw HTTPError.protocolNotSupported
    }

    return response
  }

  /// Creates a response to an error that occured while processing an HTTP request.
  open func responseFor(error: Error) -> HTTPResponse? {
    return httpConfig.errorHandler.respond(to: error)
  }

  /// Called by the worker queue to create a response to an HTTP request or possible errors.
  private func responseFor(request: HTTPRequest, error: Error?) -> HTTPResponse? {
    do {
      if let error = error { throw error }
      return try responseFor(request: request)
    } catch {
      return responseFor(error: error)
    }
  }
}

// MARK: Server properties

public extension Server {
  /// The number of concurrent requests that can be handled.
  var concurrency: Int {
    get { return workerQueue.maxConcurrentOperationCount }
    set { workerQueue.maxConcurrentOperationCount = newValue }
  }

  /// The port on which the listener is accepting connections.
  var port: Endpoint.Port {
    return listener?.port ?? 0
  }

  /// Indicates if the server is running.
  var isRunning: Bool {
    return listener?.isListening ?? false
  }

  /// Indicates if the server is secure (HTTPS).
  var isSecure: Bool {
    return tlsConfig != nil
  }

  /// The active HTTP connections.
  var httpConnections: Set<HTTPConnection> {
    return httpConnectionSet.toSet()
  }

  /// The number of active HTTP connections.
  var httpConnectionCount: Int {
    return httpConnectionSet.count
  }

  /// The active WebSocket connections.
  var webSocketConnections: Set<WebSocketConnection> {
    return webSocketConnectionSet.toSet()
  }

  /// The WebSockets currently connected to this server.
  var webSockets: [WebSocket] {
    return webSocketConnectionSet.toArray()
  }

  /// The number of active WebSocket connections.
  var webSocketCount: Int {
    return webSocketConnectionSet.count
  }
}

// MARK: TCPListenerDelegate implementation

extension Server: TCPListenerDelegate {
  /// Raised when the server's listener accepts an incoming socket connection.
  public func listener(_ listener: TCPListener, didAcceptSocket socket: TCPSocket) {
    handleIncoming(socket: socket)
  }

  /// Raised when the server's listener disconnected.
  public func listenerDisconnected(_ listener: TCPListener, error: Error?) {
    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      self.delegate?.serverDidStop(self, error: error)
      self.webSocketDelegate?.serverDidDisconnect(self)
    }
  }
}

// MARK: HTTPConnectionDelegate implementation

extension Server: HTTPConnectionDelegate {
  /// Raised when an HTTP connection receives a request.
  public func connection(_ httpConnection: HTTPConnection, handleIncomingRequest request: HTTPRequest, error: Error?) {
    handleIncoming(request: request, connection: httpConnection, error: error)
  }

  /// Raised when an HTTP connection receives a response.
  public func connection(_ httpConnection: HTTPConnection, handleIncomingResponse response: HTTPResponse, error: Error?) {
    httpConnection.close(immediately: true)
  }

  /// Raised when an HTTP connection requests a connection upgrade.
  public func connection(_ httpConnection: HTTPConnection, handleUpgradeByRequest request: HTTPRequest) {
    handleUpgrade(request: request, connection: httpConnection)
  }

  /// Raised when an HTTP connection is closed, optionally with an error.
  public func connection(_ httpConnection: HTTPConnection, didCloseWithError error: Error?) {
    httpConnectionSet.remove(httpConnection)
  }
}

// MARK: WebSocketConnectionDelegate implementation

extension Server: WebSocketConnectionDelegate {
  /// Raised when a WebSocket connection receives a message.
  public func connection(_ webSocketConnection: WebSocketConnection, didReceiveMessage message: WebSocketMessage) {
    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      self.webSocketDelegate?.server(self, webSocket: webSocketConnection, didReceiveMessage: message)
    }
  }

  /// Raised when a WebSocket connection sends a message.
  public func connection(_ webSocketConnection: WebSocketConnection, didSendMessage message: WebSocketMessage) {
    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      self.webSocketDelegate?.server(self, webSocket: webSocketConnection, didSendMessage: message)
    }
  }

  /// Raised when a WebSocket connection is closed, optionally with an error.
  public func connection(_ webSocketConnection: WebSocketConnection, didCloseWithError error: Error?) {
    webSocketConnectionSet.remove(webSocketConnection)

    delegateQueue.async { [weak self] in
      guard let self = self else { return }
      self.webSocketDelegate?.server(self, webSocketDidDisconnect: webSocketConnection, error: error)
    }
  }
}
