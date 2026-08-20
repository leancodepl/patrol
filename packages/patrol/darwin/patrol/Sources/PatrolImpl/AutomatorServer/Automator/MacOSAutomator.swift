#if PATROL_ENABLED && os(macOS)

  import XCTest
  import os

  class MacOSAutomator: Automator {

    private var timeout: TimeInterval = 10

    private lazy var device: XCUIDevice = {
      return XCUIDevice.shared
    }()

    private lazy var controlCenter: XCUIApplication = {
      return XCUIApplication(bundleIdentifier: "com.apple.controlcenter")
    }()

    private lazy var notificationCenter: XCUIApplication = {
      return XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui")
    }()

    private lazy var systemPreferences: XCUIApplication = {
      return XCUIApplication(bundleIdentifier: "com.apple.systempreferences")
    }()

    private lazy var system: XCUISystem = {
      return device.system
    }()

    func configure(timeout: TimeInterval) {
      self.timeout = timeout
    }

    func openApp(_ bundleId: String) throws {
      try runAction("opening app with id \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)
        app.activate()
      }
    }

    private func getApp(withBundleId bundleId: String) throws -> XCUIApplication {
      // UI tests always drive the app under test. Looking up by bundle id via
      // XCUIApplication(bundleIdentifier:) asserts when XCTest hasn't registered
      // that process yet (common on local unsigned macOS builds).
      _ = bundleId
      return XCUIApplication()
    }

    func pressHome() throws {
      try runAction("pressHome") {
        throw PatrolError.methodNotImplemented("pressHome")
      }
    }

    func openAppSwitcher() throws {
      try runAction("openAppSwitcher") {
        throw PatrolError.methodNotImplemented("openAppSwitcher")
      }
    }

    func openControlCenter() throws {
      try runAction("openControlCenter") {
        throw PatrolError.methodNotImplemented("openControlCenter")
      }
    }

    func openUrl(_ urlString: String) throws {
      guard let url = URL(string: urlString) else {
        throw PatrolError.internal("Invalid URL string: \(urlString)")
      }

      runAction("opening url \(url)") {
        self.system.open(url)
      }
    }

    func sendKeyboardEnter() throws {
      try runAction("sendKeyboardEnter") {
        throw PatrolError.methodNotImplemented("sendKeyboardEnter")
      }
    }

    func tap(
      on selector: IOSSelector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws {
      var view = createLogMessage(element: "view", from: selector)
      view += " in app \(bundleId)"

      try runAction("tapping on \(view)") {
        let app = try self.getApp(withBundleId: bundleId)
        // Activating the app while a menu is open closes that menu. The
        // top-level menu-bar tap activates the app; subsequent menu-item taps
        // must preserve the open menu hierarchy.
        if selector.elementType != .menuItem {
          app.activate()
        }

        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())

        Logger.shared.i("waiting for existence of \(view)")
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceClick()
      }
    }

    func doubleTap(
      on selector: IOSSelector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws {
      try runAction("doubleTap") {
        throw PatrolError.methodNotImplemented("doubleTap")
      }
    }

    func tapAt(coordinate vector: CGVector, inApp bundleId: String) throws {
      try runAction("tapAt") {
        throw PatrolError.methodNotImplemented("tapAt")
      }
    }

    func enterText(
      _ data: String,
      on selector: IOSSelector,
      inApp bundleId: String,
      dismissKeyboard: Bool,
      withTimeout timeout: TimeInterval?,
      dx: CGFloat,
      dy: CGFloat
    ) throws {
      try runAction("enterText") {
        throw PatrolError.methodNotImplemented("enterText")
      }
    }

    func enterText(
      _ data: String,
      byIndex index: Int,
      inApp bundleId: String,
      dismissKeyboard: Bool,
      withTimeout timeout: TimeInterval?,
      dx: CGFloat,
      dy: CGFloat
    ) throws {
      try runAction("enterText") {
        throw PatrolError.methodNotImplemented("enterText")
      }
    }

    func swipe(from start: CGVector, to end: CGVector, inApp bundleId: String) throws {
      try runAction("swipe") {
        throw PatrolError.methodNotImplemented("swipe")
      }
    }

    func waitUntilVisible(
      on selector: IOSSelector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws {
      let view = createLogMessage(element: "view", from: selector)
      try runAction(
        "waiting until \(view) in app \(bundleId) becomes visible"
      ) {
        let app = try self.getApp(withBundleId: bundleId)
        app.activate()

        let query = app.descendants(matching: .any).containing(selector.toNSPredicate())
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
        }
      }
    }

    // MARK: Volume settings
    func pressVolumeUp() throws {
      try runAction("pressing volume up") {
        throw PatrolError.methodNotImplemented("pressVolumeUp")
      }
    }

    func pressVolumeDown() throws {
      try runAction("pressing volume down") {
        throw PatrolError.methodNotImplemented("pressVolumeDown")
      }
    }

    func enableDarkMode(_ bundleId: String) throws {
      try runAction("enableDarkMode") {
        throw PatrolError.methodNotImplemented("enableDarkMode")
      }
    }

    func disableDarkMode(_ bundleId: String) throws {
      try runAction("disableDarkMode") {
        throw PatrolError.methodNotImplemented("disableDarkMode")
      }
    }

    func enableAirplaneMode() throws {
      try runAction("enableAirplaneMode") {
        throw PatrolError.methodNotImplemented("enableAirplaneMode")
      }
    }

    func disableAirplaneMode() throws {
      try runAction("disableAirplaneMode") {
        throw PatrolError.methodNotImplemented("disableAirplaneMode")
      }
    }

    func enableCellular() throws {
      try runAction("enableCellular") {
        throw PatrolError.methodNotImplemented("enableCellular")
      }
    }

    func disableCellular() throws {
      try runAction("disableCellular") {
        throw PatrolError.methodNotImplemented("disableCellular")
      }
    }

    func enableWiFi() throws {
      try runAction("enableWiFi") {
        throw PatrolError.methodNotImplemented("enableWiFi")
      }
    }

    func disableWiFi() throws {
      try runAction("disableWiFi") {
        throw PatrolError.methodNotImplemented("disableWiFi")
      }
    }

    func enableBluetooth() throws {
      try runAction("enableBluetooth") {
        throw PatrolError.methodNotImplemented("enableBluetooth")
      }
    }

    func disableBluetooth() throws {
      try runAction("disableBluetooth") {
        throw PatrolError.methodNotImplemented("disableBluetooth")
      }
    }

    func getNativeViews(on selector: IOSSelector, inApp bundleId: String) throws -> [IOSNativeView]
    {
      try runAction("getNativeViews") {
        throw PatrolError.methodNotImplemented("getNativeViews")
      }
    }

    func getUITreeRoots(installedApps: [String]) throws -> [IOSNativeView] {
      try runAction("getUITreeRoots") {
        throw PatrolError.methodNotImplemented("getUITreeRoots")
      }
    }

    func openNotifications() throws {
      try runAction("opening notifications") {
        let clockItem = self.controlCenter.statusItems["com.apple.menuextra.clock"]
        let exists = clockItem.waitForExistence(timeout: self.timeout)
        guard exists else {
          throw PatrolError.viewNotExists("com.apple.menuextra.clock")
        }

        clockItem.tap()
      }
    }

    func closeNotifications() throws {
      try runAction("closeNotifications") {
        throw PatrolError.methodNotImplemented("closeNotifications")
      }
    }

    func closeHeadsUpNotification() throws {
      try runAction("closeHeadsUpNotification") {
        throw PatrolError.methodNotImplemented("closeHeadsUpNotification")
      }
    }

    func getNotifications() throws -> [Notification] {
      try runAction("getNotifications") {
        throw PatrolError.methodNotImplemented("getNotifications")
      }
    }

    func tapOnNotification(byIndex index: Int, withTimeout timeout: TimeInterval?) throws {
      try runAction("tapOnNotification") {
        throw PatrolError.methodNotImplemented("tapOnNotification")
      }
    }

    func tapOnNotification(bySubstring substring: String, withTimeout timeout: TimeInterval?) throws
    {
      try runAction("tapOnNotification") {
        throw PatrolError.methodNotImplemented("tapOnNotification")
      }
    }

    func tapBackToPreviousAppButton(withTimeout timeout: TimeInterval?) throws {
      try runAction("tapBackToPreviousAppButton") {
        throw PatrolError.methodNotImplemented("tapBackToPreviousAppButton")
      }
    }

    func isPermissionDialogVisible(timeout: TimeInterval) throws -> Bool {
      try runAction("isPermissionDialogVisible") {
        throw PatrolError.methodNotImplemented("isPermissionDialogVisible")
      }
    }

    func allowPermissionWhileUsingApp() throws {
      try runAction("allowPermissionWhileUsingApp") {
        throw PatrolError.methodNotImplemented("allowPermissionWhileUsingApp")
      }
    }

    func allowPermissionOnce() throws {
      try runAction("allowPermissionOnce") {
        throw PatrolError.methodNotImplemented("allowPermissionOnce")
      }
    }

    func denyPermission() throws {
      try runAction("denyPermission") {
        throw PatrolError.methodNotImplemented("denyPermission")
      }
    }

    func selectFineLocation() throws {
      try runAction("selectFineLocation") {
        throw PatrolError.methodNotImplemented("selectFineLocation")
      }
    }

    func selectCoarseLocation() throws {
      try runAction("selectCoarseLocation") {
        throw PatrolError.methodNotImplemented("selectCoarseLocation")
      }
    }

    func setMockLocation(latitude: Double, longitude: Double) throws {
      try runAction("setMockLocation") {
        throw PatrolError.methodNotImplemented("setMockLocation")
      }
    }

    func stopMockLocation() throws {
      try runAction("stopMockLocation") {
        throw PatrolError.methodNotImplemented("stopMockLocation")
      }
    }

    func debug() throws {
      try runAction("debug") {
        throw PatrolError.methodNotImplemented("debug")
      }
    }

    /// macOS doesn't have iOS version, so return empty string
    func getOsVersion() -> String {
      return ""
    }

    /// macOS doesn't have simulators like iOS
    func isVirtualDevice() -> Bool {
      return false
    }

    @discardableResult
    private func waitFor(query: XCUIElementQuery, index: Int, timeout: TimeInterval)
      -> XCUIElement?
    {
      var foundElement: XCUIElement?
      let startTime = Date()

      while Date().timeIntervalSince(startTime) < timeout {
        let elements = query.allElementsBoundByIndex
        if index < elements.count && elements[index].exists {
          foundElement = elements[index]
          break
        }
        sleep(1)
      }

      return foundElement
    }

    private func createLogMessage(element: String, from selector: IOSSelector) -> String {
      var logMessage = element

      if let text = selector.text {
        logMessage += " with text '\(text)'"
      }
      if let startsWith = selector.textStartsWith {
        logMessage += " starting with '\(startsWith)'"
      }
      if let contains = selector.textContains {
        logMessage += " containing '\(contains)'"
      }
      if let instance = selector.instance {
        logMessage += " with instance '\(instance)'"
      }
      if let elementType = selector.elementType {
        logMessage += " with elementType '\(elementType)'"
      }
      if let identifier = selector.identifier {
        logMessage += " with identifier '\(identifier)'"
      }
      if let label = selector.label {
        logMessage += " with label '\(label)'"
      }
      if let title = selector.title {
        logMessage += " with title '\(title)'"
      }

      return logMessage
    }

    private func runAction<T>(_ log: String, block: @escaping () throws -> T) rethrows -> T {
      return try DispatchQueue.main.sync {
        Logger.shared.i("\(log)...")
        let result = try block()
        Logger.shared.i("done \(log)")
        Logger.shared.i("result: \(result)")
        return result
      }
    }
  }

  extension XCUIElement {
    fileprivate func forceClick() {
      if self.isHittable {
        self.click()
      } else {
        let coordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.click()
      }
    }
  }
#endif
