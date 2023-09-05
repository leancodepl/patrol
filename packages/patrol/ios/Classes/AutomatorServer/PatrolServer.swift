import Foundation
import FlyingFox

@objc public class PatrolServer: NSObject {
  private static let envPortKey = "PATROL_PORT"

  private static let defaultPort = 8081

  #if PATROL_ENABLED
    private let port: Int
    private let automator: Automator
    private let server: HTTPServer
//    private let dispatchGroup = DispatchGroup()
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
      self.server = HTTPServer(address: .loopback(port: UInt16(self.port)))
    #else
      Logger.shared.i("Fatal error: PATROL_ENABLED flag is not defined")
    #endif
  }

  @objc public func start() async throws {
    #if PATROL_ENABLED
      Logger.shared.i("Starting server...")
      
      let provider = AutomatorServer(automator: automator) { appReady in
        Logger.shared.i("App reported that it is ready")
        self.appReady = appReady
      }
      
      await provider.setupRoutes(server: server)
      
      Task { try await server.start() }
      try await server.waitUntilListening()
      let address = await server.listeningAddress

      Logger.shared.i("Server started on :\(address)")
     
//      dispatchGroup.enter()
//      dispatchGroup.wait()
    #endif
  }
}
