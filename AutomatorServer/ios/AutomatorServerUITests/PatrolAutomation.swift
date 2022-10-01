import XCTest

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
  
  // MARK: General
  
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
    // TODO: Implement for iPhones without notch
    
    runAction("opening app switcher") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.999))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.001))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  func openControlCenter() {
    // TODO: Implement for iPhones without notch
    
    runAction("opening control center") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.01))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.2))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  // MARK: General UI interaction
  
  func tap(on text: String, inApp appId: String) {
    runAction("tapping on text \(text)") {
      let app = XCUIApplication(bundleIdentifier: appId)
      app.descendants(matching: .any)[text].firstMatch.tap()
    }
  }

  func doubleTap(on text: String, inApp appId: String) {
    runAction("double tapping on text \(format: text)") {
      let app = XCUIApplication(bundleIdentifier: appId)
      app.descendants(matching: .any)[text].firstMatch.tap()
    }
  }

  func enterText(_ data: String, by text: String, inApp appId: String) {
    runAction("entering text \(format: data) into text field with text \(text)") {
      let app = XCUIApplication(bundleIdentifier: appId)
      app.textFields[text].firstMatch.typeText(data)
    }
  }

  func enterText(_ data: String, by index: Int, inApp appId: String) {
    runAction("entering text \(format: data) by index \(index)") {
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
  
  // MARK: Services

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
  
  func enableAirplaneMode() throws {
    try runControlCenterAction("enabling airplane mode") {
      let toggle = self.springboard.switches["airplane-mode-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }
  
  func disableAirplaneMode() throws {
    try runControlCenterAction("disabling airplane mode") {
      let toggle = self.springboard.switches["airplane-mode-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
    }
  }
  
  
  func enableCellular() throws {
    try runControlCenterAction("enabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }
  
  func disableCellular() throws {
    try runControlCenterAction("disabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
    }
  }

  func enableWiFi() throws {
    try runControlCenterAction("enabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }

  func disableWiFi() throws {
    try runControlCenterAction("disabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
    }
  }
  
  func enableBluetooth() throws {
    try runControlCenterAction("enabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      }
    }
  }
  
  func disableBluetooth() throws {
    try runControlCenterAction("disabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      }
    }
  }
  
  // MARK: Notifications
  
  func openNotifications() {
    // TODO: Check if works on iPhones without notch
    
    runAction("opening notifications") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  func closeNotifications() {
    // TODO: Check if works on iPhones without notch
    
    runAction("closing notifications") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  func closeHeadsUpNotification() async throws {
    // If the notification was triggered just now, let's wait for it
    try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
    
    runAction("closing heads up notification") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.07))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
    
    // We can't open notification shade immediately after dismissing
    // the heads-up notification. Let's wait some reasonable amount of
    // time for it.
    try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
  }
  
  
  func getNotifications() -> [Patrol_Notification] {
    var notifications = [Patrol_Notification]()
    runAction("getting notifications") {
      let cells = self.springboard.buttons.matching(identifier: "NotificationCell").allElementsBoundByIndex
      for (i, cell) in cells.enumerated() {
        let notification = Patrol_Notification.with {
          Logger.shared.i("found notification at index \(i) with label \(format: cell.label)")
          $0.raw = cell.label
        }
        notifications.append(notification)
      }
    }
    
    return notifications
  }
  
  func tapOnNotification(by index: Int) {
    runAction("tapping on notification at index \(index)") {
      let cells = self.springboard.buttons.matching(identifier: "NotificationCell").allElementsBoundByIndex
      guard cells.indices.contains(index) else {
        Logger.shared.e("notification at index \(index) doesn't exist")
        return
      }
      
      cells[index].tap()
      self.springboard.staticTexts.matching(identifier: "Open").firstMatch.tap()
    }
  }
  
  func tapOnNotification(by text: String) {
    runAction("tapping on notification containing text \(format: text)") {
      let cells = self.springboard.buttons.matching(identifier: "NotificationCell").allElementsBoundByIndex
      for (i, cell) in cells.enumerated() {
        if cell.label.contains(text) {
          Logger.shared.i("tapping on notification at index \(i) which contains text \(text)")
          cell.tap()
          self.springboard.staticTexts.matching(identifier: "Open").firstMatch.tap()
          return
        }
      }
      
      Logger.shared.e("no notification contains text \(format: text)")
    }
  }
  
  // MARK: Permissions
  
  func allowPermissionWhileUsingApp() {
    runAction("allowing while using app") {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK", "Allow", "Allow While Using App"]
      
      for label in labels {
        Logger.shared.i("checking if button \(format: label) exists")
        let button = systemAlerts.buttons[label]
        if button.exists {
          Logger.shared.i("found button \(format: label)")
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
        Logger.shared.i("checking if button \(format: label) exists")
        let button = systemAlerts.buttons[label]
        if button.exists {
          Logger.shared.i("found button \(format: label)")
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
  
  // MARK: Other
  
  func debug() throws {
    runAction("debug()") {
      // TODO: Remove later
      for i in 0...150 {
        let element = self.springboard.descendants(matching: .any).element(boundBy: i)
        if !element.exists {
          break
        }
        
        let label = element.label as String
        let accLabel = element.accessibilityLabel as String?
        let ident = element.identifier
        
        if label.isEmpty && accLabel?.isEmpty ?? true && ident.isEmpty {
          continue
        }
        
        Logger.shared.i("index: \(i), label: \(label), accLabel: \(String(describing: accLabel)), ident: \(ident)")
      }
    }
  }
  
  private func runControlCenterAction(_ log: String,block: @escaping () -> Void) throws {
    #if targetEnvironment(simulator)
      throw PatrolError.generic("Control Center is not available on Simulator")
    #endif
    
    runAction(log) {
      self.openControlCenter()
      
      // perform the action
      block()
      
      // hide control center
      let empty = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1))
      empty.tap()
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

extension String.StringInterpolation {
  mutating func appendInterpolation(format value: String) {
      appendInterpolation("\"\(value)\"")
  }
}
