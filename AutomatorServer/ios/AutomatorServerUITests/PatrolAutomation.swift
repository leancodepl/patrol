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

  private lazy var preferences: XCUIApplication = {
    return XCUIApplication(bundleIdentifier: "com.apple.Preferences")
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

  func openAppSwitcher() {
    runAction("opening app switcher") {
      let swipeStart = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.999))
      let swipeEnd = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.001))
      swipeStart.press(forDuration: 0.1, thenDragTo: swipeEnd)
    }
  }

  func enableDarkMode(_ bundleIdentifier: String) {
    runAction("enabling dark mode") {
      #if targetEnvironment(simulator)
        let isSimulator = true
      #else
        let isSimulator = false
      #endif
      
      self.springboard.activate()
      self.preferences.terminate() // reset to a known state
      self.preferences.activate()
      
      if (isSimulator) {
        self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()
        
        let value = self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value! as! String
        if value == "0" {
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.tap()
        }
      } else {
        self.preferences.descendants(matching: .any)["Display & Brightness"].firstMatch.tap()
        self.preferences.descendants(matching: .any)["Dark"].firstMatch.tap()
      }
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
    }
  }

  func disableDarkMode(_ bundleIdentifier: String) {
    runAction("disabling dark mode") {
      #if targetEnvironment(simulator)
        let isSimulator = true
      #else
        let isSimulator = false
      #endif

      self.springboard.activate()
      self.preferences.terminate() // reset to a known state
      self.preferences.activate()
      if (isSimulator) {
        self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()
        
        let value = self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value! as! String
        if value == "1" {
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.tap()
        }
      } else {
        self.preferences.descendants(matching: .any)["Display & Brightness"].firstMatch.tap()
        self.preferences.descendants(matching: .any)["Light"].firstMatch.tap()
      }
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
    }
  }

  func enableWiFi(_ bundleIdentifier: String) {
    runAction("enabling wifi") {
      self.springboard.activate()
      self.preferences.terminate()
      self.preferences.activate()  // reset to a known state
      self.preferences.descendants(matching: .any)["Wi-Fi"].firstMatch.tap()
      let value = self.preferences.switches.firstMatch.value! as! String
      if value == "0" {
        self.preferences.switches.firstMatch.tap()
      }
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
    }
  }

  func disableWiFi(_ bundleIdentifier: String) {
    runAction("disabling wifi") {
      self.springboard.activate()
      self.preferences.terminate()
      self.preferences.activate()  // reset to a known state
      self.preferences.descendants(matching: .any)["Wi-Fi"].firstMatch.tap()
      let value = self.preferences.switches.firstMatch.value! as! String
      if value == "1" {
        self.preferences.switches.firstMatch.tap()
      }
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
    }
  }
  
  func enableCellular(_ bundleIdentifier: String) throws {
    #if targetEnvironment(simulator)
      throw PatrolError.generic("cellular is not supported on simulator")
    #endif
    
    runAction("enabling cellular") {
      self.springboard.activate()
      self.preferences.terminate()
      self.preferences.activate()  // reset to a known state
      self.preferences.descendants(matching: .any)["Cellular"].firstMatch.tap()
      let value = self.preferences.switches.firstMatch.value! as! String
      if value == "0" {
        self.preferences.switches.firstMatch.tap()
      }
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
    }
  }
  
  func disableCellular(_ bundleIdentifier: String) throws {
    #if targetEnvironment(simulator)
      throw PatrolError.generic("cellular is not supported on simulator")
    #endif
    
    runAction("disabling cellular") {
      self.springboard.activate()
      self.preferences.terminate()
      self.preferences.activate()  // reset to a known state
      self.preferences.descendants(matching: .any)["Cellular"].firstMatch.tap()
      let value = self.preferences.switches.firstMatch.value! as! String
      if value == "1" {
        self.preferences.switches.firstMatch.tap()
      }
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
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

  func allowPermissionWhileUsingApp() {
    runAction("allowing while using app") {
      let systemAlerts = self.springboard.alerts
      let okButton = systemAlerts.buttons["OK"]
      if okButton.exists {
        okButton.tap()
      }
      
      let allowWhileUsingButton = systemAlerts.buttons["Allow While Using App"]
      if allowWhileUsingButton.exists {
        allowWhileUsingButton.tap()
      }
    }
  }

  func allowPermissionOnce() {
    runAction("allowing once") {
      let systemAlerts = self.springboard.alerts
      let allowOnceButton = systemAlerts.buttons["Allow Once"]
      if allowOnceButton.exists {
        allowOnceButton.tap()
      }
    }
  }

  func denyPermission() {
    runAction("denying permission") {
      let systemAlerts = self.springboard.alerts
      let denyButton = systemAlerts.buttons["Don't Allow"]
      if denyButton.exists {
        denyButton.tap()
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
