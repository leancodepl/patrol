import Foundation
#if os(iOS)
import Telegraph
#elseif os(macOS)
import FlyingFox
#endif

@objc public class PatrolServer: NSObject {
  private static let envPortKey = "PATROL_PORT"

  private static let defaultPort = 8081

  #if PATROL_ENABLED
    private let port: Int
    private let automator: Automator
    #if os(iOS)
      private let server: Server
    #elseif os(macOS)
      private let server: HTTPServer
    #endif
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
      #if os(iOS)
        self.automator = IOSAutomator()
        self.server = Server()
      #elseif os(macOS)
        self.server = HTTPServer(address: .loopback(port: UInt16(self.port)))
        self.automator = MacOSAutomator()
      #endif
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
      
      #if os(iOS)
        provider.setupRoutes(server: server)

        try server.start(port: port)
      #elseif os(macOS)
        await provider.setupRoutes(server: server)
      
        Task { try await server.start() }
        try await server.waitUntilListening()
        let address = await server.listeningAddress
      #endif
      

      Logger.shared.i("Server started on :\(address)")
     
//      dispatchGroup.enter()
//      dispatchGroup.wait()
    #endif
  }
}
