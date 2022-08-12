import XCTest

class ServerLoop: XCTestCase {
  func testRunMaestroServer() throws {
    Logger.shared.i("Starting server loop...")

    
    let maestroServer = try MaestroServer()

    do {
      try maestroServer.start()
    } catch let err {
      Logger.shared.e("Failed to start server: \(err)")
      maestroServer.stop()
    }
  }
}
