import XCTest

struct NativeWidget: Codable {
  var className: String
  var text: String
}

class PatrolAutomation {
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

  func tap(on text: String, inApp appId: String) {
    runAction("tapping on \(text)") {
      let app = XCUIApplication(bundleIdentifier: appId)
      app.descendants(matching: .any)[text].firstMatch.tap()
    }
  }

  func doubleTap(on text: String, inApp appId: String) {
    runAction("double tapping on \"\(text)\"") {
      let app = XCUIApplication(bundleIdentifier: appId)
      app.descendants(matching: .any)[text].firstMatch.tap()
    }
  }

  func enterText(_ data: String, by text: String, inApp appId: String) {
    runAction("entering text \"\(text)\"") {
      let app = XCUIApplication(bundleIdentifier: appId)
      app.textFields[text].firstMatch.typeText(data)
    }
  }

  func enterText(_ data: String, by index: Int, inApp appId: String) {
    runAction("entering text \"\(data)\" by index \(index)") {
      let app = XCUIApplication(bundleIdentifier: appId)
      let textField = app.textFields.element(boundBy: index)
      if textField.exists {
        textField.tap()
        textField.typeText(data)
      } else {
        Logger.shared.e("textField at index \(index) doesn't exist")
      }

    }
  }

  func handlePermission(code: Patrol_HandlePermissionCommand.Code) {
    runAction("handling permission with code \(code)") {
      let systemAlerts = self.springboard.alerts
      switch code {
      case .whileUsing:
        let okButton = systemAlerts.buttons["OK"]
        if okButton.exists {
          okButton.tap()
        }

        let allowWhileUsingButton = systemAlerts.buttons["Allow While Using App"]
        if allowWhileUsingButton.exists {
          allowWhileUsingButton.tap()
        }
      case .onlyThisTime:
        let allowOnceButton = systemAlerts.buttons["Allow Once"]
        if allowOnceButton.exists {
          allowOnceButton.tap()
        }
      case .denied:
        let denyButton = systemAlerts.buttons["Don't Allow"]
        if denyButton.exists {
          denyButton.tap()
        }
      case .UNRECOGNIZED:
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
