import XCTest

class ServerLoop: XCTestCase {
  func testRunPatrolServer() async throws {
    Logger.shared.i("Starting server loop...")

    let patrolServer = PatrolServer(testCase: self)
    try await patrolServer.start()
  }
}
