import Embassy
import EnvoyAmbassador

class MaestroServer {
  private let loop = try! SelectorEventLoop(selector: try! KqueueSelector())

  private let automation = MaestroAutomation()

  func onRequest(
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
        guard let map = json as? [String:Any] else {
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
    let server = DefaultHTTPServer(eventLoop: loop, port: 8081, app: onRequest)
    try! server.start()
    Logger.shared.i("Server started")
    loop.runForever()
  }

  func stop() {
    loop.stop()
  }
}
