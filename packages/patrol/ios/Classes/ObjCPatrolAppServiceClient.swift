/// Simplified objective-c RunDartTestResponse model that we use in PatrolIntegrationTestRunner.h
@objc public class ObjCRunDartTestResponse: NSObject {
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
    // https://github.com/leancodepl/patrol/issues/1683
    let timeout = TimeInterval(2 * 60 * 60)

    NSLog("PatrolAppServiceClient: created, port: \(port)")

    client = PatrolAppServiceClient(port: port, address: "localhost", timeout: timeout)
  }

  @objc public func listDartTests(completion: @escaping ([String]?, Error?) -> Void) {
    NSLog("PatrolAppServiceClient.listDartTests()")

    client.listDartTests { result in
      switch result {
      case .success(let result):
        let output = result.group.listTestsFlat(parentGroupName: "").map {
          $0.name
        }
        completion(output, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }

  @objc public func listDartLifecycleCallbacks(
    completion: @escaping ([String]?, [String]?, Error?) -> Void
  ) {
    NSLog("PatrolAppService.listDartLifecycleCallbacks()")

    client.listDartLifecycleCallbacks { result in
      switch result {
      case .success(let result):
        completion(result.setUpAlls, result.tearDownAlls, nil)
      case .failure(let error):
        completion(nil, nil, error)
      }
    }
  }

  @objc public func setDartLifecycleCallbacksState(
    _ state: [String: Bool], completion: @escaping (Error?) -> Void
  ) {
    NSLog("PatrolAppService.setDartLifecycleCallbacksState(\(state)")

    let request = SetLifecycleCallbacksStateRequest(state: state)
    self.client.setLifecycleCallbacksState(request: request) { result in
      switch result {
      case .success(_):
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }

  @objc public func runDartTest(
    _ name: String, completion: @escaping (ObjCRunDartTestResponse?, Error?) -> Void
  ) {
    NSLog("PatrolAppServiceClient.runDartTest(\(format: name))")

    let request = RunDartTestRequest(name: name)
    self.client.runDartTest(request: request) { result in
      switch result {
      case .success(let result):
        let testRespone = ObjCRunDartTestResponse(
          passed: result.result == .success,
          details: result.details
        )
        completion(testRespone, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
}

extension DartGroupEntry {

  func listTestsFlat(parentGroupName: String) -> [DartGroupEntry] {
    var tests = [DartGroupEntry]()

    for test in self.entries {
      var test = test

      if test.type == GroupEntryType.test {
        if parentGroupName.isEmpty {
          // This case is invalid, because every test will have at least
          // 1 named group - its filename.

          fatalError("Invariant violated: test \(format: test.name) has no named parent group")
        }

        test.name = "\(parentGroupName) \(test.name)"
        tests.append(test)
      } else if test.type == GroupEntryType.group {
        if parentGroupName.isEmpty {
          tests.append(contentsOf: test.listTestsFlat(parentGroupName: test.name))
        } else {
          tests.append(
            contentsOf: test.listTestsFlat(parentGroupName: "\(parentGroupName) \(test.name)")
          )
        }
      }
    }

    return tests
  }
}
