import GRPC
import NIOCore
import Foundation
import NIOPosix
import XCTest

class PatrolServer {
  private static let envPortKey = "PATROL_PORT"

  private let port: Int

  private let automator: Automator

  private var passedPort: Int? = {
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      Logger.shared.i("\(envPortKey) is null")
      return nil
    }

    return Int(portStr)
  }()

  init() {
    self.port = passedPort ?? 8081
    self.automator = Automator()
  }

  func start() async throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  
    let provider = NativeAutomatorServer(automator: automator)
    
    let server = try await Server.insecure(group: group).withServiceProviders([provider]).bind(host: "0.0.0.0", port: port).get()
    
    Logger.shared.i("Server started on http://localhost:\(port)")

    try await server.onClose.get()
    Logger.shared.i("Server stopped")
  }
}
