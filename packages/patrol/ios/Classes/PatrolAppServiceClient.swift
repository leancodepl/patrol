import GRPC
import NIO
import Logging

// Swift Protobufs can't be used in Objective-C
@objc public class RunDartTestResponse: NSObject {
  @objc public dynamic let passed: Bool
  @objc public dynamic let details: String?

  @objc public init(passed: Bool, details: String?) {
    self.passed = passed
    self.details = details
  }
}

// TODO: Rewrite to be blocking (we don' need for completion handlers)
@objc public class PatrolAppServiceClient : NSObject {
    
    private let client: Patrol_PatrolAppServiceAsyncClient
    
    /**
     * Construct client for accessing PatrolAppService server using the existing channel.
     */
    @objc public override init() {
        let target = "localhost:8082" // TODO: Document this value better
        Logger.shared.i("Created PatrolAppServiceClient, target: \(target)")
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let channel = ClientConnection.insecure(group: group).connect(host: target, port: 8082)
        
        // Passing Channels to code makes code easier to test and makes it easier to reuse Channels.
        client = Patrol_PatrolAppServiceAsyncClient(channel: channel)
    }
    
    
    @objc public func listDartTests() async throws -> [String] {
        let request = Patrol_Empty()
        let response = try await client.listDartTests(request)
        
        return response.group.groups.map { $0.name }
    }
    
    @objc public func runDartTest(name: String) async throws -> RunDartTestResponse {
        let request = Patrol_RunDartTestRequest.with { $0.name = name }
        let result = try await client.runDartTest(request)
        
    
        
        return RunDartTestResponse(
            passed: result.result == .success,
            details: result.details
        )
    }
}

