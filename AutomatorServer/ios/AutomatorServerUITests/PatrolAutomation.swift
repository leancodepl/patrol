import XCTest

class PatrolAutomation {
  private static let defaultTimeout = TimeInterval(10)
  
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
  
  func pressHome() throws {
    try runAction("pressing home button") {
      self.device.press(XCUIDevice.Button.home)
    }
  }

  func openApp(_ bundleIdentifier: String) throws {
    try runAction("opening app with id \(bundleIdentifier)") {
      let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
      app.activate()
    }
  }

  func openAppSwitcher() throws {
    // TODO: Implement for iPhones without notch
    
    try runAction("opening app switcher") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.999))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.001))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  func openControlCenter() throws {
    // TODO: Implement for iPhones without notch
    
    try runAction("opening control center") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.01))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.2))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  // MARK: General UI interaction
  
  func tap(on text: String, inApp appId: String) throws {
    try runAction("tapping on text \(text)") {
      let app = XCUIApplication(bundleIdentifier: appId)
      let element = app.descendants(matching: .any)[text]
      
      guard element.exists else {
        throw PatrolError.elementNotFound(element)
      }
      
      element.firstMatch.tap()
    }
  }

  func doubleTap(on text: String, inApp appId: String) throws {
    try runAction("double tapping on text \(format: text)") {
      let element = XCUIApplication(bundleIdentifier: appId)
      
      guard element.exists else {
        throw PatrolError.elementNotFound(element)
      }
      
      element.descendants(matching: .any)[text].firstMatch.tap()
    }
  }

  func enterText(_ data: String, by text: String, inApp appId: String) throws {
    try runAction("entering text \(format: data) into text field with text \(text)") {
      let element = XCUIApplication(bundleIdentifier: appId).textFields[text]
      
      guard element.exists else {
        throw PatrolError.elementNotFound(element)
      }
      
      element.firstMatch.typeText(data)
    }
  }

  func enterText(_ data: String, by index: Int, inApp appId: String) throws {
    try runAction("entering text \(format: data) by index \(index)") {
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

  func enableDarkMode(_ bundleIdentifier: String) throws {
    try runSettingsAction("enabling dark mode", bundleIdentifier) {
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

  func disableDarkMode(_ bundleIdentifier: String) throws {
    try runSettingsAction("disabling dark mode", bundleIdentifier) {
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
      } else {
        Logger.shared.i("airplane mode is already enabled")
      }
    }
  }
  
  func disableAirplaneMode() throws {
    try runControlCenterAction("disabling airplane mode") {
      let toggle = self.springboard.switches["airplane-mode-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("airplane mode is already disabled")
      }
    }
  }
  
  
  func enableCellular() throws {
    try runControlCenterAction("enabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      } else {
        Logger.shared.i("cellular is already enabled")
      }
    }
  }
  
  func disableCellular() throws {
    try runControlCenterAction("disabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("cellular is already disabled")
      }
    }
  }

  func enableWiFi() throws {
    try runControlCenterAction("enabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      } else {
        Logger.shared.i("wifi is already enabled")
      }
    }
  }

  func disableWiFi() throws {
    try runControlCenterAction("disabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("wifi is already disabled")
      }
    }
  }
  
  func enableBluetooth() throws {
    try runControlCenterAction("enabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      } else {
        Logger.shared.i("bluetooth is already enabled")
      }
    }
  }
  
  func disableBluetooth() throws {
    try runControlCenterAction("disabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("bluetooth is already disabled")
      }
    }
  }
  
  // MARK: Notifications
  
  func openNotifications() throws {
    // TODO: Check if works on iPhones without notch
    
    try runAction("opening notifications") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  func closeNotifications() throws {
    // TODO: Check if works on iPhones without notch
    
    try runAction("closing notifications") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }
  
  func closeHeadsUpNotification() async throws {
    // If the notification was triggered just now, let's wait for it
    try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
    
    try runAction("closing heads up notification") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.07))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
    
    // We can't open notification shade immediately after dismissing
    // the heads-up notification. Let's wait some reasonable amount of
    // time for it.
    try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
  }
  
  
  func getNotifications() throws -> [Patrol_Notification] {
    var notifications = [Patrol_Notification]()
    try runAction("getting notifications") {
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
  
  func tapOnNotification(by index: Int) throws {
    try runAction("tapping on notification at index \(index)") {
      let cells = self.springboard.buttons.matching(identifier: "NotificationCell").allElementsBoundByIndex
      guard cells.indices.contains(index) else {
        Logger.shared.e("notification at index \(index) doesn't exist")
        return
      }
      
      cells[index].tap()
      self.springboard.staticTexts.matching(identifier: "Open").firstMatch.tap()
    }
  }
  
  func tapOnNotification(by text: String) throws {
    try runAction("tapping on notification containing text \(format: text)") {
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
  
  func allowPermissionWhileUsingApp() throws {
    try runAction("allowing while using app") {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK", "Allow", "Allow While Using App"]
      
      var match = false
      for label in labels {
        Logger.shared.i("checking if button \(format: label) exists")
        let button = systemAlerts.buttons[label]
        if button.exists {
          Logger.shared.i("found button \(format: label)")
          match = true
          button.tap()
          break
        }
      }
      
      if !match {
        throw PatrolError.generic("none of \(dump(labels)) exist")
      }
    }
  }

  func allowPermissionOnce() throws {
    try runAction("allowing once") {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK", "Allow", "Allow Once"]
      
      var match = false
      for label in labels {
        Logger.shared.i("checking if button \(format: label) exists")
        let button = systemAlerts.buttons[label]
        if button.exists {
          Logger.shared.i("found button \(format: label)")
          match = true
          button.tap()
          break
        }
      }
      
      if !match {
        throw PatrolError.generic("none of \(dump(labels)) exist")
      }
    }
  }

  func denyPermission() throws {
    try runAction("denying permission") {
      let systemAlerts = self.springboard.alerts
      let button = systemAlerts.buttons["Don’t Allow"] // not "Don't Allow"!

      guard button.exists else {
        throw PatrolError.generic("button \(button) doesn't exist")
      }
      
      button.tap()
    }
  }

  func selectFineLocation() throws {
    try runAction("selecting fine location") {
      let alerts = self.springboard.alerts
      let button = alerts.buttons["Precise: Off"]
      
      guard button.exists else {
        throw PatrolError.generic("button \(button) doesn't exist")
      }
      
      button.tap()
    }
  }
  
  func selectCoarseLocation() throws {
    try runAction("selecting coarse location") {
      let alerts = self.springboard.alerts
      let button = alerts.buttons["Precise: On"]
      
      guard button.exists else {
        throw PatrolError.generic("button \(button) doesn't exist")
      }
      
      button.tap()
    }
  }
  
  // MARK: Other
  
  func debug() throws {
    try runAction("debug()") {
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
  
  // MARK: Private stuff
  
  private func tapIfExists(_ element: XCUIElement) throws {
    guard element.exists else {
      throw PatrolError.elementNotFound(element)
    }
    
    element.firstMatch.tap()
  }
  
  private func runControlCenterAction(_ log: String, block: @escaping () -> Void) throws {
    #if targetEnvironment(simulator)
      throw PatrolError.generic("Control Center is not available on Simulator")
    #endif
    
    try runAction(log) {
      try self.openControlCenter()
      
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
  ) throws {
    try runAction(log) {
      self.springboard.activate()
      self.preferences.launch()  // reset to a known state
      
      block()
      
      self.springboard.activate()
      self.preferences.terminate()
      XCUIApplication(bundleIdentifier: bundleIdentifier).activate() // go back to the app under test
    }
  }

  private func runAction(_ log: String, block: @escaping () throws -> Void) throws {
    try dispatchOnMainThread {
      Logger.shared.i("\(log)...")
      try block()
      Logger.shared.i("done \(log)")
    }
  }

  private func dispatchOnMainThread(block: @escaping () throws -> Void) throws {
    let group = DispatchGroup()
    var err: Error?
    
    group.enter()
    DispatchQueue.main.async {
      defer {
        group.leave()
      }
      
      do {
        try block()
      } catch let error {
        err = error
      }
    }
    
    group.wait()
    
    if err != nil {
      throw err!
    }
  }
}

// MARK: Utilities


extension String.StringInterpolation {
  mutating func appendInterpolation(format value: String) {
      appendInterpolation("\"\(value)\"")
  }
}
