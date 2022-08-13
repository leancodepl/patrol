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
    Logger.shared.i("pressing home button...")
    device.press(XCUIDevice.Button.home)
    Logger.shared.i("done")
  }

  func openApp(_ bundleIdentifier: String) {
    Logger.shared.i("opening app with bundle id \(bundleIdentifier)...")
    let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
    app.activate()
    Logger.shared.i("done")
  }
}
