import XCTest

class ServerLoop: XCTestCase {
  func testRunMaestroServer() async throws {
    Logger.shared.i("Starting server loop...")

    let maestroServer = try MaestroServer()
    maestroServer.start()

    while maestroServer.isRunning {}
  }
}
