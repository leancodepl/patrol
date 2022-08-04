import XCTest

class ServerLoop: XCTestCase {
  func testRunMaestroServer() {
    Logger.shared.i("Starting server...")

    let maestroServer = MaestroServer()
    do {
      try maestroServer.start()
    } catch let error {
      Logger.shared.i("error: \(error)")
      maestroServer.stop()
    }

    Logger.shared.i("Server stopped")
  }
}
