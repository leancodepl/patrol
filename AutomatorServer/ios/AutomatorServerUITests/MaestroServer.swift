import GCDWebServer

class MaestroServer {
  private let envPortKey = "MAESTRO_PORT"

  private let port: Int

  private let server: GCDWebServer

  private let startTime: String

  private let automation = MaestroAutomation()

  var isRunning: Bool {
    server.isRunning
  }

  init() throws {
    //    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
    //      throw MaestroError.generic("\(envPortKey) is null")
    //    }
    //    guard let port = Int(portStr) else {
    //      throw MaestroError.generic("\(envPortKey)=\(portStr) is not an Int")
    //    }
    self.port = 8081

    self.server = GCDWebServer()

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    startTime = dateFormatter.string(from: Date())
  }

  func router(
    environ: [String: Any],
    startResponse: @escaping ((String, [(String, String)]) -> Void),
    sendBody: @escaping ((Data) -> Void)
  ) {
    let pathInfo = environ["PATH_INFO"]! as! String
    let method = environ["REQUEST_METHOD"]! as! String
    Logger.shared.i("\(method) \(pathInfo)")

    let index = pathInfo.index(pathInfo.startIndex, offsetBy: 1)  // ugly Swift
    let action = String(pathInfo[index...])

    switch (method, action) {
    case ("GET", ""):
      startResponse("200 OK", [])
      sendBody(Data("Hello from AutomatorServer on iOS!\nStarted on \(startTime)".utf8))
      sendBody(Data())  // send EOF
    case ("GET", "isRunning"):
      startResponse("200 OK", [])
      sendBody(Data("All is good.".utf8))
      sendBody(Data())  // send EOF
    case ("POST", "stop"):
      self.stop()
      startResponse("200 OK", [])
      sendBody(Data())  // send EOF
    case ("POST", "pressHome"):
      self.automation.pressHome()
      startResponse("200 OK", [])
      sendBody(Data())  // send EOF
    case ("POST", "openApp"):
      Logger.shared.i("openApp")
    //      let input = environ["swsgi.input"] as! SWSGIInput
    //      JSONReader.read(input) { json in
    //        guard let map = json as? [String: Any] else {
    //          Logger.shared.i("Failed to type assert")
    //          return
    //        }
    //        let bundleId = map["id"] as! String
    //        self.automation.openApp(bundleId)
    //        startResponse("200 OK", [])
    //        sendBody(Data())  // send EOF
    //      }
    default:
      startResponse("404 Not Found", [])
      sendBody(Data())  // send EOF
    }
  }

  func start() {
    Logger.shared.i("Starting server...")
    server.addDefaultHandler(
      forMethod: "GET", request: GCDWebServerRequest.self,
      asyncProcessBlock: { request, completionBlock in
        completionBlock(GCDWebServerDataResponse(text: "Hello world"))
      })

    do {
      try server.start(options: [
        GCDWebServerOption_Port: port,
        GCDWebServerOption_BindToLocalhost: true,
      ])
      logServerStarted()
    } catch let err {
      Logger.shared.e("Failed to start server: \(err)")
    }
  }

  func stop() {
    Logger.shared.i("Stopping server...")
    server.stop()
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
