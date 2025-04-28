import Foundation

@objc public class PatrolServer: NSObject {
  private static let envPortKey = "PATROL_TEST_SERVER_PORT"

  @objc
  public var port: Int = 0
  @objc
  public var appServerPort: Int = 0
  #if PATROL_ENABLED
    private let automator: Automator
    private let server: Server
  #endif

  @objc
  public var appReady = false

  private var passedPort: Int = {
    // FIXME: Test server port is not null when not set in running tests command ('test-without-building')
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      Logger.shared.i("\(envPortKey) is null, will use random free port")
      return 0
    }

    guard let portInt = Int(portStr) else {
      Logger.shared.i(
        "\(envPortKey) with value \(portStr) is not valid, will use random free port instead"
      )
      return 0
    }

    return portInt
  }()

  @objc public override init() {
    Logger.shared.i("PatrolServer constructor called")

    #if PATROL_ENABLED
      Logger.shared.i("PATROL_ENABLED flag is defined")
      self.port = passedPort
      self.server = Server()
      #if os(iOS)
        self.automator = IOSAutomator()
      #elseif os(macOS)
        self.automator = MacOSAutomator()
      #endif
    #else
      Logger.shared.i("Fatal error: PATROL_ENABLED flag is not defined")
    #endif
  }

  @objc public func start() throws {
    #if PATROL_ENABLED
      Logger.shared.i("Starting server...")

      let provider = AutomatorServer(automator: automator) { appReady, appServerPort in
        Logger.shared.i("App reported that it is ready on port \(appServerPort)")
        self.appReady = appReady
        self.appServerPort = appServerPort
      }

      provider.setupRoutes(server: server)

      try server.start(port: Endpoint.Port(UInt16(passedPort)))
      self.port = server.port

      Logger.shared.i("Server started on http://0.0.0.0:\(server.port)")
    #endif
  }
}
