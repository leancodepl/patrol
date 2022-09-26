import XCTest

class ServerLoop: XCTestCase {
  func testRunPatrolServer() async throws {
    Logger.shared.i("Starting server loop...")

    let patrolServer = PatrolServer()
    try await patrolServer.start()
  }
}
