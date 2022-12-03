import Foundation
import GRPC
import NIOCore
import NIOPosix
import XCTest

@objc public class PatrolServer : NSObject {
  private static let envPortKey = "PATROL_PORT"
  
  private static let defaultPort = 8081

  private let port: Int

  private let automator: Automator

  private var passedPort: Int = {
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      Logger.shared.i("\(envPortKey) is null, falling back to default: \(defaultPort)")
      return defaultPort
    }

    guard let portInt = Int(portStr) else {
      Logger.shared.i("\(envPortKey) with value \(portStr) is not valid, falling back to default: \(defaultPort)")
      return defaultPort
    }
    
    return portInt
  }()

  @objc public override init() {
    self.port = passedPort
    self.automator = Automator()
  }

  @objc public func start() async throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

    let provider = NativeAutomatorServer(automator: automator)

    let server = try await Server.insecure(group: group).withServiceProviders([provider]).bind(
      host: "0.0.0.0", port: port
    ).get()

    Logger.shared.i("Server started on http://localhost:\(port)")

    try await server.onClose.get()
    Logger.shared.i("Server stopped")
  }
}
