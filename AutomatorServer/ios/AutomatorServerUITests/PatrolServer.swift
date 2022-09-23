import GRPC
import NIOCore
import NIOPosix

struct DarkModeCommand: Codable {
  var appId: String
}

class PatrolServer {
  private static let envPortKey = "PATROL_PORT"

  private let port: Int

  private let automation = PatrolAutomation()

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
  }

  func start() async throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    let provider = NativeAutomatorServer()
    
    let server = try await Server.insecure(group: group).withServiceProviders([provider]).bind(host: "localhost", port: port).get()
    
    print("server started on port \(server.channel.localAddress!.port!)")

    // Wait on the server's `onClose` future to stop the program from exiting.
    try await server.onClose.get()
  }

  func stop() {
    Logger.shared.i("Stopping server...")
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
