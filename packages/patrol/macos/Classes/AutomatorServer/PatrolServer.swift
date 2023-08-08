import Foundation
import grpc
import NIOPosix

@objc public class PatrolServer: NSObject {
  private static let envPortKey = "PATROL_PORT"

  private static let defaultPort = 8081

  #if PATROL_ENABLED
    private let port: Int
    private let automator: Automator
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
      self.automator = Automator()
    #else
      Logger.shared.i("Fatal error: PATROL_ENABLED flag is not defined")
    #endif
  }

  @objc public func start() async throws {
    #if PATROL_ENABLED
      let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
      appReady = true
//      let provider = AutomatorServer(automator: automator) { appReady in
//        Logger.shared.i("App reported that it is ready")
//        self.appReady = appReady
//      }
//
//      let server = try await Server.insecure(group: group).withServiceProviders([provider]).bind(
//        host: "0.0.0.0", port: port
//      ).get()

      Logger.shared.i("Server started on http://localhost:\(port)")

//      try await server.onClose.get()
      Logger.shared.i("Server stopped")
    #endif
  }
}
