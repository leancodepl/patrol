import XCTest

class ServerLoop: XCTestCase {
  func testRunMaestroServer() {
    print("Starting server...")

    let maestroServer = MaestroServer()
    do {
      try maestroServer.start()
      print("Server started")
    } catch let error {
      print("error: \(error)")
      maestroServer.stop()
    }
  }
}
