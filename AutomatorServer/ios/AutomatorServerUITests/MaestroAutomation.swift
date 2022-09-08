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

  private lazy var springboard: XCUIApplication = {
    return XCUIApplication(bundleIdentifier: "com.apple.springboard")
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

  func tap(onSystemDialog text: String) {
    runAction("tapping on system dialog \(text)") {
      let alerts = self.springboard.alerts
      if alerts.buttons[text].exists {
        alerts.buttons[text].tap()
      }
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
    let found = app.descendants(matching: .any).containing(
      NSPredicate(format: "label CONTAINS '\(query.text)'"))

    return []  // TODO: finish
  }

  func handlePermission(code: String) {
    runAction("handling permission with code \(code)") {
      let systemAlerts = self.springboard.alerts
      switch code {
      case "WHILE_USING":
        let okButton = systemAlerts.buttons["OK"]
        if okButton.exists {
          okButton.tap()
        }

        let allowWhileUsingButton = systemAlerts.buttons["Allow While Using App"]
        if allowWhileUsingButton.exists {
          allowWhileUsingButton.tap()
        }
      case "ONLY_THIS_TIME":
        let allowOnceButton = systemAlerts.buttons["Allow Once"]
        if allowOnceButton.exists {
          allowOnceButton.tap()
        }
      case "DENIED":
        let denyButton = systemAlerts.buttons["Don't Allow"]
        if denyButton.exists {
          denyButton.tap()
        }
      default:
        Logger.shared.e("Invalid code: \(code)")
      }
    }
  }

  func selectFineLocation() {
    runAction("selecting fine location") {
      let alerts = self.springboard.alerts
      if alerts.buttons["Precise: Off"].exists {
        alerts.buttons["Precise: Off"].tap()
      }
    }
  }

  func selectCoarseLocation() {
    runAction("selecting coarse location") {
      let alerts = self.springboard.alerts
      if alerts.buttons["Precise: On"].exists {
        alerts.buttons["Precise: On"].tap()
      }
    }
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
