import XCTest

class MaestroAutomation {
  private lazy var app: XCUIApplication = {
    return XCUIApplication()
  }()

  private lazy var device: XCUIDevice = {
    return XCUIDevice.shared
  }()

  var ipAddress: String? {
    return device.wiFiIPAddress()
  }

  func pressHome() {
    dispatchOnMainThread {
      let msg = "pressing home button"
      Logger.shared.i("\(msg)...")
      self.device.press(XCUIDevice.Button.home)
      Logger.shared.i("done \(msg)")
    }
  }

  func openApp(_ bundleIdentifier: String) {
    dispatchOnMainThread {
      let msg = "opening app with bundle id \(bundleIdentifier)"
      Logger.shared.i("\(msg)...")
      let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
      app.activate()
      Logger.shared.i("done \(msg)")
    }
  }

  private func dispatchOnMainThread(block: @escaping () -> Void) {
    let group = DispatchGroup()
    group.enter()
    DispatchQueue.main.async {
      block()
      group.leave()
    }

    group.wait()
  }
}
