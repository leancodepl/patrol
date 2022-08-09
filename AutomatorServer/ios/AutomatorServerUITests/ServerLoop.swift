import XCTest

class ServerLoop: XCTestCase {
  func testRunMaestroServer() {
    Logger.shared.i("Starting server...")

    let maestroServer = MaestroServer()
    handlePopups()
    do {
      try maestroServer.start()
    } catch let error {
      Logger.shared.i("error: \(error)")
      maestroServer.stop()
    }
  }

  func handlePopups() {
//    addUIInterruptionMonitor(withDescription: "Access to sound recording") { (alert) -> Bool in
//      Logger.shared.i("interruption caught")
//      if alert.staticTexts["Odkryj Rudy would like to find and connect to devices on your local network."]
//        .exists
//      {
//        alert.buttons["OK"].tap()
//      } else {
//        alert.buttons["Don’t Allow"].tap()
//      }
//      return true
//    }
  }
}
