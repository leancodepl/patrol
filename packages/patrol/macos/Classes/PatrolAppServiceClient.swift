import grpc
import OSLog
import NIOPosix

/// The sole reason for existence of this class is that Swift Protobufs can't be used in Objective-C.
@objc public class RunDartTestResponse: NSObject {
  @objc public dynamic let passed: Bool
  @objc public dynamic let details: String?

  @objc public init(passed: Bool, details: String?) {
    self.passed = passed
    self.details = details
  }
}

/// Provides access to Patrol's test services running inside the app under test.
///
/// The client must do its work off the main thread. Otherwise, a deadlock will quickly appear.
/// That's because the main thread is used by methods in ``Automator``, which perform
/// various UI actions such as tapping, entering text, etc., and they must be called on the main thread.
@objc public class PatrolAppServiceClient: NSObject {

//  private let client: Patrol_PatrolAppServiceAsyncClient

  /// Construct client for accessing PatrolAppService server using the existing channel.
  @objc public override init() {
    let port = 8082  // TODO: Document this value better
    NSLog("PatrolAppServiceClient: created, port: \(port)")
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//    let channel = try! GRPCChannelPool.with(
//      target: .host("localhost", port: port),
//      transportSecurity: .plaintext,
//      eventLoopGroup: group
//    )

//    client = Patrol_PatrolAppServiceAsyncClient(channel: channel)
  }

  @objc public func listDartTests() async throws -> [String] {
    NSLog("PatrolAppServiceClient.listDartTests()")
//    let request = Patrol_Empty()
//    let response = try await client.listDartTests(request)

//    return response.group.groups.map { $0.name }
      return []
  }

  @objc public func runDartTest(name: String) async throws -> RunDartTestResponse {
    NSLog("PatrolAppServiceClient.runDartTest(\(name))")
//    let request = Patrol_RunDartTestRequest.with { $0.name = name }
//    let result = try await client.runDartTest(request)
      

    return RunDartTestResponse(
      passed: true,
      details: ""
    )
  }
}
