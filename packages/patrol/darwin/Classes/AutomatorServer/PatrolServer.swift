import Foundation

@objc public class PatrolServer: NSObject {
  private static let envPortKey = "PATROL_TEST_PORT"

  private static let defaultPort = 8081
    
  #if PATROL_ENABLED
    @objc
    public var port: Int = 0
    private let automator: Automator
    private let server: Server
  #endif

  @objc
  public private(set) var appReady = false

  private var passedPort: Int = {
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      Logger.shared.i("\(envPortKey) is null, falling back to default (\(defaultPort))")
      return defaultPort
    }

    guard let portInt = Int(portStr) else {
      Logger.shared.i(
        "\(envPortKey) with value \(portStr) is not valid, falling back to default (\(defaultPort))"
      )
      return defaultPort
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

      let provider = AutomatorServer(automator: automator) { appReady in
        Logger.shared.i("App reported that it is ready")
        self.appReady = appReady
      }

      provider.setupRoutes(server: server)

      try server.start()
      self.port = server.port

      Logger.shared.i("Server started on http://0.0.0.0:\(server.port)")
    #endif
  }
}
