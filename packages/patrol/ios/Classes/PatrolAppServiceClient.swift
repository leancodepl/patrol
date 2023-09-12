import GRPC
import Logging
import NIO

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

  private let client: Patrol_PatrolAppServiceAsyncClient

  /// Construct client for accessing PatrolAppService server using the existing channel.
  @objc public override init() {
    let port = 8082  // TODO: Document this value better
    NSLog("PatrolAppServiceClient: created, port: \(port)")
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let channel = try! GRPCChannelPool.with(
      target: .host("localhost", port: port),
      transportSecurity: .plaintext,
      eventLoopGroup: group
    )

    client = Patrol_PatrolAppServiceAsyncClient(channel: channel)
  }

  @objc public func listDartTests() async throws -> [String] {
    NSLog("PatrolAppServiceClient.listDartTests()")
    let request = Patrol_Empty()
    let response = try await client.listDartTests(request)

    NSLog("RAW: Got tests: \(response.group)")

    return response.group.listTestsFlat(parentGroupName: "").map {
      $0.name
    }
  }

  @objc public func runDartTest(name: String) async throws -> RunDartTestResponse {
    NSLog("PatrolAppServiceClient.runDartTest(\(name))")
    let request = Patrol_RunDartTestRequest.with { $0.name = name }
    let result = try await client.runDartTest(request)

    return RunDartTestResponse(
      passed: result.result == .success,
      details: result.details
    )
  }
}

extension Patrol_DartGroupEntry {

  func listTestsFlat(parentGroupName: String) -> [Patrol_DartGroupEntry] {
    var tests = [Patrol_DartGroupEntry]()

    for test in self.entries {
      if test.type == Patrol_DartGroupEntry.GroupEntryType.test {
        if parentGroupName.isEmpty {
          // This case is invalid, because every test will have at least
          // 1 named group - its filename.

          continue  // What else can we do?
        }

        // TODO: There has to be some copy() function
        tests.append(
          .with {
            $0.name = "\(parentGroupName) \(test.name)"
            $0.fullName = test.fullName
            $0.type = test.type
            $0.entries = test.entries
          })
      } else if test.type == Patrol_DartGroupEntry.GroupEntryType.group {
        if parentGroupName.isEmpty {
          tests.append(contentsOf: test.listTestsFlat(parentGroupName: test.name))
        } else {
          tests.append(
            contentsOf: test.listTestsFlat(parentGroupName: "\(parentGroupName) \(test.name)"))
        }
      }
    }

    return tests
  }
}
