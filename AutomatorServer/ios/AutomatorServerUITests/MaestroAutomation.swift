import XCTest

struct NativeWidget: Codable {
  var className: String
  var text: String
}

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
    runAction("pressing home button") {
      self.device.press(XCUIDevice.Button.home)
    }
  }

  func openApp(_ bundleIdentifier: String) {
    runAction("opening app with id \(bundleIdentifier)") {
      let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
      app.activate()
    }
  }

  func tap(on text: String) {
    runAction("tapping on \(text)") {
      let app = XCUIApplication(bundleIdentifier: "pl.leancode.maestro.Example")
      app.descendants(matching: .any)[text].tap()
    }
  }
  
  func enterText(into text: String, withContent data: String) {
    runAction("entering text \"\(text)\"") {
      let app = XCUIApplication(bundleIdentifier: "pl.leancode.maestro.Example")
      app.textFields[text].typeText(data)
    }
  }
  
  func getNativeWidgets(query: SelectorQuery) -> [NativeWidget] {
    let app = XCUIApplication(bundleIdentifier: "pl.leancode.maestro.Example")
    let found = app.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS '\(query.text)'"))
    
    return [] // TODO: finish
  }
  
  private func runAction(_ log: String, block: @escaping () -> Void) {
    dispatchOnMainThread {
      Logger.shared.i("\(log)...")
      block()
      Logger.shared.i("done \(log)")
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
