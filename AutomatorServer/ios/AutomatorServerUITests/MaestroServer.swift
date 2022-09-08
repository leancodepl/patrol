import Telegraph

struct OpenAppCommand: Codable {
  var id: String
}

struct TapCommand: Codable {
  var appId: String
  var selector: Selector
}

struct DoubleTapCommand: Codable {
  var appId: String
  var selector: Selector
}

struct EnterTextCommand: Codable {
  var appId: String
  var data: String
  var selector: Selector
}

struct PermissionCommand: Codable {
  var code: String
}

struct Selector: Codable {
  var text: String
}

class MaestroServer {
  private static let envPortKey = "MAESTRO_PORT"

  private let port: Int

  private let server: Server

  private let automation = MaestroAutomation()

  private let dispatchGroup = DispatchGroup()

  private let decoder = JSONDecoder()

  private var passedPort: Int? = {
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      Logger.shared.i("\(envPortKey) is null")
      return nil
    }
    
     return Int(portStr)
  }()

  init() throws {
    self.port = passedPort ?? 8081
    self.server = Server()
  }

  func setUpRoutes() {
    server.route(.GET, "") { request in
      HTTPResponse(content: "Hello from AutomatorServer on iOS!")
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
      do {
        let command = try self.decoder.decode(OpenAppCommand.self, from: request.body)
        self.automation.openApp(command.id)
        return HTTPResponse(.ok)
      } catch let err {
        return HTTPResponse(.badRequest, headers: [:], error: err)
      }
    }

    server.route(.POST, "tap") { request in
      do {
        let command = try self.decoder.decode(TapCommand.self, from: request.body)
        self.automation.tap(on: command.selector.text, inApp: command.appId)
        return HTTPResponse(.ok)
      } catch let err {
        return HTTPResponse(.badRequest, headers: [:], error: err)
      }
    }
    
    server.route(.POST, "doubleTap") { request in
      do {
        let command = try self.decoder.decode(DoubleTapCommand.self, from: request.body)
        self.automation.doubleTap(on: command.selector.text, inApp: command.appId)
        return HTTPResponse(.ok)
      } catch let err {
        return HTTPResponse(.badRequest, headers: [:], error: err)
      }
    }

    server.route(.POST, "enterText") { request in
      do {
        let command = try self.decoder.decode(EnterTextCommand.self, from: request.body)
        self.automation.enterText(into: command.selector.text, withContent: command.data)
        return HTTPResponse(.ok)
      } catch let err {
        return HTTPResponse(.badRequest, headers: [:], error: err)
      }
    }

    server.route(.POST, "handlePermission") { request in
      do {
        let command = try self.decoder.decode(PermissionCommand.self, from: request.body)
        self.automation.handlePermission(code: command.code)
        return HTTPResponse(.ok)
      } catch let err {
        return HTTPResponse(.badRequest, headers: [:], error: err)
      }
    }

    server.route(.POST, "selectFineLocation") { request in
      self.automation.selectFineLocation()
      return HTTPResponse(.ok)
    }

    server.route(.POST, "selectCoarseLocation") { request in
      self.automation.selectCoarseLocation()
      return HTTPResponse(.ok)
    }
  }

  func start() throws {
    Logger.shared.i("Starting server...")
    do {
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
