import Embassy
import EnvoyAmbassador

class MaestroServer {
  private let envPortKey = "MAESTRO_PORT"
  
  private let port: Int

  private let loop: EventLoop

  init() throws {
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      throw MaestroError.generic("\(envPortKey) is null")
    }
    guard let port = Int(portStr) else {
      throw MaestroError.generic("\(envPortKey)=\(portStr) is not an Int")
    }
    self.port = port

    guard let kQueueSelector = try? KqueueSelector() else {
      throw MaestroError.generic("Failed to create KqueueSelector")
    }
    guard let loop = try? SelectorEventLoop(selector: kQueueSelector) else {
      throw MaestroError.generic("Failed to create SelectorEventLoop")
    }
    self.loop = loop
  }

  private let automation = MaestroAutomation()

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
      sendBody(Data("Hello from AutomatorServer on iOS!".utf8))
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
      let input = environ["swsgi.input"] as! SWSGIInput
      JSONReader.read(input) { json in
        guard let map = json as? [String: Any] else {
          Logger.shared.i("Failed to type assert")
          return
        }
        let bundleId = map["id"] as! String
        self.automation.openApp(bundleId)
        startResponse("200 OK", [])
        sendBody(Data())  // send EOF
      }
    default:
      startResponse("404 Not Found", [])
      sendBody(Data())  // send EOF
    }
  }

  func start() throws {
    Logger.shared.i("Starting server...")
    let server = DefaultHTTPServer(eventLoop: loop, interface: "::", port: port, app: router)
    try server.start()
    Logger.shared.i("Server started on http://\(automation.ipAddress!):\(port) (http://localhost:\(port))")
    loop.runForever()
    Logger.shared.i("Server stopped (loop finished)")
  }

  func stop() {
    Logger.shared.i("Stopping server...")
    loop.stop()
    Logger.shared.i("Server stopped")
  }
}
