/// The sole reason for existence of this class is that Swift Protobufs can't be used in Objective-C.
@objc public class RunDartTestResponse2: NSObject {
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
@objc public class ObjCPatrolAppServiceClient: NSObject {

   private let client: PatrolAppServiceClient

  /// Construct client for accessing PatrolAppService server using the existing channel.
  @objc public override init() {
    let port = 8082  // TODO: Document this value better
    
    NSLog("PatrolAppServiceClient: created, port: \(port)")
    
    client = PatrolAppServiceClient(port: port, address: "localhost")
  }

  @objc public func listDartTests() async throws -> [String] {
    NSLog("PatrolAppServiceClient.listDartTests()")

    let response = try await client.listDartTests()

    return response.group.groups.map { $0.name }
  }

  @objc public func runDartTest(name: String) async throws -> RunDartTestResponse2 {
    try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))

    NSLog("PatrolAppServiceClient.runDartTest(\(name))")

     let request = RunDartTestRequest(name: name)
     let result = try await client.runDartTest(request: request)

     return RunDartTestResponse2(
       passed: result.result == .success,
       details: result.details
     )
  }
}
