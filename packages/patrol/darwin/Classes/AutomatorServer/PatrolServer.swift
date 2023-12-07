import Foundation

@objc public class PatrolServer: NSObject {
  private static let envPortKey = "PATROL_PORT"

  private static let defaultPort = 8081

  #if PATROL_ENABLED
    private let port: Int
    private let automator: Automator
    private let server: Server
  #endif

  private let onAppReady: () -> Void

  private let onDartLifecycleCallbackExecuted: (String) -> Void

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

  @objc public init(
    withOnAppReadyCallback onAppReady: @escaping () -> Void,
    onDartLifecycleCallbackExecuted: @escaping (String) -> Void
  ) {
    self.onDartLifecycleCallbackExecuted = onDartLifecycleCallbackExecuted
    self.onAppReady = onAppReady
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

      let provider = AutomatorServer(
        automator: automator,
        onAppReady: {
          Logger.shared.i("App reported that it is ready")
          self.onAppReady()
        },
        onDartLifecycleCallbackExecuted: { callback in
          Logger.shared.i(
            "App reported that Dart lifecycle callback \(format: callback) was executed")
          self.onDartLifecycleCallbackExecuted(callback)
        }
      )

      provider.setupRoutes(server: server)

      try server.start(port: port)

      Logger.shared.i("Server started on http://0.0.0.0:\(port)")
    #endif
  }
}
