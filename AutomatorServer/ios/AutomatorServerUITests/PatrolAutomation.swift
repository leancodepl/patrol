import XCTest

struct NativeWidget: Codable {
  var className: String
  var text: String
}

class PatrolAutomation {
  private lazy var device: XCUIDevice = {
    return XCUIDevice.shared
  }()

  private lazy var springboard: XCUIApplication = {
    return XCUIApplication(bundleIdentifier: "com.apple.springboard")
  }()

  private lazy var preferences: XCUIApplication = {
    return XCUIApplication(bundleIdentifier: "com.apple.Preferences")
  }()
  
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
    runSettingsAction("enabling dark mode", bundleIdentifier) {
      #if targetEnvironment(simulator)
        self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()
        
        let value = self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value! as! String
        if value == "0" {
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.tap()
        }
      #else
        self.preferences.descendants(matching: .any)["Display & Brightness"].firstMatch.tap()
        self.preferences.descendants(matching: .any)["Dark"].firstMatch.tap()
      #endif
    }
  }

  func disableDarkMode(_ bundleIdentifier: String) {
    runSettingsAction("disabling dark mode", bundleIdentifier) {
      #if targetEnvironment(simulator)
        self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()
        
        let value = self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value! as! String
        if value == "1" {
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.tap()
        }
      #else
        self.preferences.descendants(matching: .any)["Display & Brightness"].firstMatch.tap()
        self.preferences.descendants(matching: .any)["Light"].firstMatch.tap()
      #endif
    }
  }
  
  // MARK: Services
  
  func enableAirplaneMode(_ bundleIdentifier: String) throws {
    try runControlCenterAction("enabling airplane mode") {
      let toggle = self.springboard.switches["airplane-mode-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }
  
  func disableAirplaneMode(_ bundleIdentifier: String) throws {
    try runControlCenterAction("disabling airplane mode") {
      let toggle = self.springboard.switches["airplane-mode-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
    }
  }
  
  
  func enableCellular(_ bundleIdentifier: String) throws {
    try runControlCenterAction("enabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }
  
  func disableCellular(_ bundleIdentifier: String) throws {
    try runControlCenterAction("disabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
    }
  }

  func enableWiFi(_ bundleIdentifier: String) throws {
    try runControlCenterAction("enabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }

  func disableWiFi(_ bundleIdentifier: String) throws {
    try runControlCenterAction("disabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
    }
  }
  
  func enableBluetooth(_ bundleIdentifier: String) throws {
    try runControlCenterAction("enabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }
  
  func disableBluetooth(_ bundleIdentifier: String) throws {
    try runControlCenterAction("disabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
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
      let labels = ["OK", "Allow", "Allow While Using App"]
      
      for label in labels {
        Logger.shared.i("Checking if button \"\(label)\" exists")
        let button = systemAlerts.buttons[label]
        if button.exists {
          Logger.shared.i("Found button \"\(label)\"")
          button.tap()
          break
        }
      }
    }
  }

  func allowPermissionOnce() {
    runAction("allowing once") {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK", "Allow", "Allow Once"]
      
      for label in labels {
        Logger.shared.i("Checking if button \"\(label)\" exists")
        let button = systemAlerts.buttons[label]
        if button.exists {
          Logger.shared.i("Found button \"\(label)\"")
          button.tap()
          break
        }
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
  
  private func runControlCenterAction(_ log: String,block: @escaping () -> Void) throws {
    #if targetEnvironment(simulator)
      throw PatrolError.generic("Control Center is not available on Simulator")
    #endif
    
    // FIXME: implement for iPhones without notch
    
    runAction(log) {
      // open control center
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.01))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.2))
      start.press(forDuration: 0.1, thenDragTo: end)
      
      // perform the action
      block()
      
      // hide control center
      let empty = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1))
      empty.tap()
    }
  }
  
  func getNativeWidgets() throws {
    // TODO: Remove later
    for i in 0...10 {
      let toggle = self.springboard.switches.element(boundBy: i)
      let label = toggle.label as String
      let accLabel = toggle.accessibilityLabel as String?
      let ident = toggle.identifier
      Logger.shared.i("index: \(i), label: \(label), accLabel: \(String(describing: accLabel)), ident: \(ident)")
    }
  }
  
  private func runSettingsAction(
    _ log: String,
    _ bundleIdentifier: String,
    block: @escaping () -> Void
  ) {
    runAction(log) {
      self.springboard.activate()
      self.preferences.launch()  // reset to a known state
      
      block()
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
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
