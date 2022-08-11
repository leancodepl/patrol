import XCTest

class ServerLoop: XCTestCase {
  func testRunMaestroServer() throws {
    Logger.shared.i("Starting server loop...")

    
    let maestroServer: MaestroServer
    do {
      maestroServer = try MaestroServer()
    } catch let err {
      throw err
    }

    setUpInterruptionMonitor()
    
    do {
      try maestroServer.start()
    } catch let err {
      Logger.shared.e("Failed to start server: \(err)")
      maestroServer.stop()
    }
  }

  func setUpInterruptionMonitor() {
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
