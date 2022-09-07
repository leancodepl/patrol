import XCTest

class ServerLoop: XCTestCase {
  func testRunMaestroServer() async throws {
    Logger.shared.i("Starting server loop...")

    let maestroServer = try MaestroServer()
    maestroServer.start()

    try! await Task.sleep(nanoseconds: UInt64(10 * 60 * Double(NSEC_PER_SEC)))
  }
}
