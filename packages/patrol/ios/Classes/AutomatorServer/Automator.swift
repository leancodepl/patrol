import XCTest

class Automator {
  private lazy var device: XCUIDevice = {
    return XCUIDevice.shared
  }()

  private lazy var springboard: XCUIApplication = {
    return XCUIApplication(bundleIdentifier: "com.apple.springboard")
  }()

  private lazy var preferences: XCUIApplication = {
    return XCUIApplication(bundleIdentifier: "com.apple.Preferences")
  }()

  private var timeout: TimeInterval = 10

  func configure(timeout: TimeInterval) {
    self.timeout = timeout
  }

  // MARK: General

  func pressHome() async throws {
    await runAction("pressing home button") {
      self.device.press(XCUIDevice.Button.home)
    }
  }

  func openApp(_ bundleId: String) async throws {
    try await runAction("opening app with id \(bundleId)") {
      let app = try self.getApp(withBundleId: bundleId)
      app.activate()
    }
  }

  func openAppSwitcher() async throws {
    // TODO: Implement for iPhones without notch

    await runAction("opening app switcher") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.999))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.001))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }

  func openControlCenter() async throws {
    // TODO: Implement for iPhones without notch

    await runAction("opening control center") {
      self.swipeToOpenControlCenter()
    }
  }

  // MARK: General UI interaction

  func tap(on text: String, inApp bundleId: String) async throws {
    try await runAction("tapping on view with text \(format: text)") {
      let app = try self.getApp(withBundleId: bundleId)
      let element = app.descendants(matching: .any)[text]

      Logger.shared.i("waiting for existence of view with text \(format: text)")
      let exists = element.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("view with text \(format: text) in app \(format: bundleId)")
      }
      Logger.shared.i("found view with text \(format: text), will tap on it")

      element.firstMatch.forceTap()
    }
  }

  func doubleTap(on text: String, inApp bundleId: String) async throws {
    try await runAction("double tapping on text \(format: text)") {
      let app = try self.getApp(withBundleId: bundleId)
      let element = app.descendants(matching: .any)[text]

      let exists = element.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("view with text \(format: text) in app \(format: bundleId)")
      }

      element.firstMatch.forceTap()
    }
  }

  func enterText(_ data: String, by text: String, inApp bundleId: String) async throws {
    try await runAction("entering text \(format: data) into text field with text \(text)") {
      let app = try self.getApp(withBundleId: bundleId)
      let element = app.textFields[text]

      guard
        let element = self.waitForAnyElement(
          elements: [app.textFields[text], app.secureTextFields[text]],
          timeout: self.timeout
        )
      else {
        throw PatrolError.viewNotExists(
          "text field with text \(format: text) in app \(format: bundleId)")
      }

      element.firstMatch.typeText(data)
    }
  }

  func enterText(_ data: String, by index: Int, inApp bundleId: String) async throws {
    try await runAction("entering text \(format: data) by index \(index)") {
      let app = try self.getApp(withBundleId: bundleId)

      // elementType must be specified as integer
      // See:
      // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypetextfield
      // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypesecuretextfield
      let textFieldPredicate = NSPredicate(format: "elementType == 49")
      let secureTextFieldPredicate = NSPredicate(format: "elementType == 50")
      let predicate = NSCompoundPredicate(
        orPredicateWithSubpredicates: [textFieldPredicate, secureTextFieldPredicate]
      )

      let textFields = app.descendants(matching: .any).matching(predicate)
      let textFieldCount = textFields.allElementsBoundByIndex.count
      Logger.shared.i("found \(textFields.count) text fields")
      guard index < textFieldCount else {
        throw PatrolError.viewNotExists("text field at index \(index)")
      }

      let textField = textFields.element(boundBy: index)
      textField.forceTap()
      textField.typeText(data)
    }
  }

  // MARK: Services

  func enableDarkMode(_ bundleId: String) async throws {
    try await runSettingsAction("enabling dark mode", bundleId) {
      #if targetEnvironment(simulator)
        self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()

        let value =
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value!
          as! String
        if value == "0" {
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.tap()
        }
      #else
        self.preferences.descendants(matching: .any)["Display & Brightness"].firstMatch.tap()
        self.preferences.descendants(matching: .any)["Dark"].firstMatch.tap()
      #endif
    }
  }

  func disableDarkMode(_ bundleId: String) async throws {
    try await runSettingsAction("disabling dark mode", bundleId) {
      #if targetEnvironment(simulator)
        self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()

        let value =
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value!
          as! String
        if value == "1" {
          self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.tap()
        }
      #else
        self.preferences.descendants(matching: .any)["Display & Brightness"].firstMatch.tap()
        self.preferences.descendants(matching: .any)["Light"].firstMatch.tap()
      #endif
    }
  }

  func enableAirplaneMode() async throws {
    try await runControlCenterAction("enabling airplane mode") {
      let toggle = self.springboard.switches["airplane-mode-button"]
      if toggle.value! as! String == "0" {
        toggle.tap()
      } else {
        Logger.shared.i("airplane mode is already enabled")
      }
    }
  }

  func disableAirplaneMode() async throws {
    try await runControlCenterAction("disabling airplane mode") {
      let toggle = self.springboard.switches["airplane-mode-button"]
      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("airplane mode is already disabled")
      }
    }
  }

  func enableCellular() async throws {
    try await runControlCenterAction("enabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      let exists = toggle.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("cellular-data-button")
      }

      if toggle.value! as! String == "0" {
        toggle.tap()
      } else {
        Logger.shared.i("cellular is already enabled")
      }
    }
  }

  func disableCellular() async throws {
    try await runControlCenterAction("disabling cellular") {
      let toggle = self.springboard.switches["cellular-data-button"]
      let exists = toggle.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("cellular-data-button")
      }

      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("cellular is already disabled")
      }
    }
  }

  func enableWiFi() async throws {
    try await runControlCenterAction("enabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      let exists = toggle.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("wifi-button")
      }

      if toggle.value! as! String == "0" {
        toggle.tap()
      } else {
        Logger.shared.i("wifi is already enabled")
      }
    }
  }

  func disableWiFi() async throws {
    try await runControlCenterAction("disabling wifi") {
      let toggle = self.springboard.switches["wifi-button"]
      let exists = toggle.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("wifi-button")
      }

      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("wifi is already disabled")
      }
    }
  }

  func enableBluetooth() async throws {
    try await runControlCenterAction("enabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      let exists = toggle.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("bluetooth-button")
      }

      if toggle.value! as! String == "0" {
        toggle.tap()
      } else {
        Logger.shared.i("bluetooth is already enabled")
      }
    }
  }

  func disableBluetooth() async throws {
    try await runControlCenterAction("disabling bluetooth") {
      let toggle = self.springboard.switches["bluetooth-button"]
      let exists = toggle.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("bluetooth-button")
      }

      if toggle.value! as! String == "1" {
        toggle.tap()
      } else {
        Logger.shared.i("bluetooth is already disabled")
      }
    }
  }

  // MARK: Notifications

  func openNotifications() async throws {
    // TODO: Check if works on iPhones without notch

    await runAction("opening notifications") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }

  func closeNotifications() async throws {
    // TODO: Check if works on iPhones without notch

    await runAction("closing notifications") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
      start.press(forDuration: 0.1, thenDragTo: end)
    }
  }

  func closeHeadsUpNotification() async throws {
    // If the notification was triggered just now, let's wait for it
    try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))

    await runAction("closing heads up notification") {
      let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
      let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.07))
      start.press(forDuration: 0.1, thenDragTo: end)
    }

    // We can't open notification shade immediately after dismissing
    // the heads-up notification. Let's wait some reasonable amount of
    // time for it.
    try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
  }

  func getNotifications() async throws -> [Patrol_Notification] {
    var notifications = [Patrol_Notification]()
    await runAction("getting notifications") {
      let cells = self.springboard.buttons.matching(identifier: "NotificationCell")
        .allElementsBoundByIndex
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

  func tapOnNotification(by index: Int) async throws {
    try await runAction("tapping on notification at index \(index)") {
      let cells = self.springboard.buttons.matching(identifier: "NotificationCell")
        .allElementsBoundByIndex
      guard cells.indices.contains(index) else {
        throw PatrolError.viewNotExists("notification at index \(index)")
      }

      cells[index].tap()
      self.springboard.staticTexts.matching(identifier: "Open").firstMatch.tap()
    }
  }

  func tapOnNotification(by text: String) async throws {
    try await runAction("tapping on notification containing text \(format: text)") {
      let cells = self.springboard.buttons.matching(identifier: "NotificationCell")
        .allElementsBoundByIndex
      for (i, cell) in cells.enumerated() {
        if cell.label.contains(text) {
          Logger.shared.i("tapping on notification at index \(i) which contains text \(text)")
          cell.tap()
          self.springboard.staticTexts.matching(identifier: "Open").firstMatch.tap()
          return
        }
      }

      throw PatrolError.viewNotExists("notification containing text \(format: text)")
    }
  }

  // MARK: Permissions

  func isPermissionDialogVisible(timeout: TimeInterval) async -> Bool {
    return await runAction("checking if permission dialog is visible") {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK", "Allow", "Allow once", "Allow While Using App", "Don’t Allow"]

      let button = self.waitForAnyElement(
        elements: labels.map { systemAlerts.buttons[$0] },
        timeout: timeout
      )

      return button != nil
    }
  }

  func allowPermissionWhileUsingApp() async throws {
    try await runAction("allowing while using app") {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK", "Allow", "Allow While Using App"]

      guard
        let button = self.waitForAnyElement(
          elements: labels.map { systemAlerts.buttons[$0] },
          timeout: self.timeout
        )
      else {
        throw PatrolError.viewNotExists("button to allow permission only once")
      }

      button.tap()
    }
  }

  func allowPermissionOnce() async throws {
    try await runAction("allowing once") {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK", "Allow", "Allow Once"]

      guard
        let button = self.waitForAnyElement(
          elements: labels.map { systemAlerts.buttons[$0] },
          timeout: self.timeout
        )
      else {
        throw PatrolError.viewNotExists("button to allow permission only once")
      }

      button.tap()
    }
  }

  func denyPermission() async throws {
    try await runAction("denying permission") {
      let label = "Don’t Allow"  // not "Don't Allow"!
      let systemAlerts = self.springboard.alerts
      let button = systemAlerts.buttons[label]

      let exists = button.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("button to deny permission")
      }

      button.tap()
    }
  }

  func selectFineLocation() async throws {
    try await runAction("selecting fine location") {
      let alerts = self.springboard.alerts
      let button = alerts.buttons["Precise: Off"]

      let exists = button.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("button to select fine location")
      }

      button.tap()
    }
  }

  func selectCoarseLocation() async throws {
    try await runAction("selecting coarse location") {
      let alerts = self.springboard.alerts
      let button = alerts.buttons["Precise: On"]

      let exists = button.waitForExistence(timeout: self.timeout)
      guard exists else {
        throw PatrolError.viewNotExists("button to select coarse location")
      }

      button.tap()
    }
  }

  // MARK: Other

  func debug() async throws {
    await runAction("debug()") {
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

        Logger.shared.i(
          "index: \(i), label: \(label), accLabel: \(String(describing: accLabel)), ident: \(ident)"
        )
      }
    }
  }

  // MARK: Private stuff

  /// Adapted from https://stackoverflow.com/q/47880395/7009800
  @discardableResult
  func waitForAnyElement(elements: [XCUIElement], timeout: TimeInterval) -> XCUIElement? {
    var foundElement: XCUIElement?
    let startTime = Date()

    while Date().timeIntervalSince(startTime) < timeout {
      if let elementFound = elements.first(where: { $0.exists }) {
        foundElement = elementFound
        break
      }
      sleep(1)
    }

    return foundElement
  }

  private func getApp(withBundleId bundleId: String) throws -> XCUIApplication {
    let app = XCUIApplication(bundleIdentifier: bundleId)
    // TODO: Doesn't work
    // See https://stackoverflow.com/questions/73976961/how-to-check-if-any-app-is-installed-during-xctest
    // guard app.exists else {
    //   throw PatrolError.appNotInstalled(bundleId)
    // }

    return app
  }

  private func swipeToOpenControlCenter() {
    let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.01))
    let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.2))
    start.press(forDuration: 0.1, thenDragTo: end)
  }

  private func runControlCenterAction(_ log: String, block: @escaping () throws -> Void)
    async throws
  {
    #if targetEnvironment(simulator)
      throw PatrolError.internal("Control Center is not available on Simulator")
    #endif

    try await runAction(log) {
      self.swipeToOpenControlCenter()

      // perform the action
      try block()

      // hide control center
      let empty = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1))
      empty.tap()
    }
  }

  private func runSettingsAction(
    _ log: String,
    _ bundleId: String,
    block: @escaping () -> Void
  ) async throws {
    try await runAction(log) {
      self.springboard.activate()
      self.preferences.launch()  // reset to a known state

      block()

      self.springboard.activate()
      
      // Workaround for https://github.com/leancodepl/patrol/issues/681
      #if PATROL_ENABLED
        self.preferences.terminate()
      #else
      Logger.shared.e("tried to call XCUIApplication.terminate, but PATROL_ENABLED is not defined. This is an error.")
      #endif

      // go back to the app under test
      let app = try self.getApp(withBundleId: bundleId)
      app.activate()
    }
  }

  private func runAction<T>(_ log: String, block: @escaping () throws -> T) async rethrows -> T {
    return try await MainActor.run {
      Logger.shared.i("\(log)...")
      let result = try block()
      Logger.shared.i("done \(log)")
      return result
    }
  }
}

// MARK: Utilities

extension String.StringInterpolation {
  mutating func appendInterpolation(format value: String) {
    appendInterpolation("\"\(value)\"")
  }
}

// Adapted from https://samwize.com/2016/02/28/everything-about-xcode-ui-testing-snapshot/
extension XCUIElement {
  func forceTap() {
    if self.isHittable {
      self.tap()
    } else {
      let coordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
      coordinate.tap()
    }
  }
}
