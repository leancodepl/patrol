import Telegraph

struct OpenAppCommand: Codable {
  var id: String
}

class MaestroServer {
  private let envPortKey = "MAESTRO_PORT"

  private let port: Int

  private let server: Server

  private let startTime: String

  private let automation = MaestroAutomation()

  private let dispatchGroup = DispatchGroup()

  var isRunning: Bool {
    server.isRunning
  }

  init() throws {
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      throw MaestroError.generic("\(envPortKey) is null")
    }
    guard let port = Int(portStr) else {
      throw MaestroError.generic("\(envPortKey)=\(portStr) is not an Int")
    }
    self.port = port

    self.server = Server()

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    startTime = dateFormatter.string(from: Date())
  }

  func setUpRoutes() {
    server.route(.GET, "") { request in
      HTTPResponse(content: "Hello from AutomatorServer on iOS!\nStarted on \(self.startTime)")
    }

    server.route(.GET, "isRunning") { request in
      HTTPResponse(.ok, headers: [:], content: "All is good.")
    }

    server.route(.POST, "stop") { request in
      self.stop()
      return HTTPResponse(.ok)
    }

    server.route(.POST, "pressHome") { request in
      self.automation.pressHome()
      return HTTPResponse(.ok)
    }

    server.route(.POST, "openApp") { request in
      let decoder = JSONDecoder()
      do {
        let command = try decoder.decode(OpenAppCommand.self, from: request.body)
        self.automation.openApp(command.id)
        return HTTPResponse(.ok)
      } catch let err {
        return HTTPResponse(.badRequest, headers: [:], error: err)
      }
    }
  }

  func start() throws {
    Logger.shared.i("Starting server...")
    do {
      server.route(.GET, "/") { (.ok, "Hello from AutomatorServer on iOS") }
      try server.start(port: 8081)
      setUpRoutes()
      dispatchGroup.enter()
      logServerStarted()
    } catch let err {
      Logger.shared.e("Failed to start server: \(err)")
      throw err
    }

    dispatchGroup.wait()
  }

  func stop() {
    Logger.shared.i("Stopping server...")
    server.stop()
    dispatchGroup.leave()
    Logger.shared.i("Server stopped")
  }

  func logServerStarted() {
    if let ip = automation.ipAddress {
      Logger.shared.i("Server started on http://\(ip):\(port) (http://localhost:\(port))")
    } else {
      Logger.shared.i("Server started on http://localhost:\(port)")
    }
  }
}
