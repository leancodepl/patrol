#if PATROL_ENABLED
  import XCTest
  import os

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

    func pressHome() throws {
      runAction("pressing home button") {
        self.device.press(XCUIDevice.Button.home)
      }
    }

    func openApp(_ bundleId: String) throws {
      try runAction("opening app with id \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)
        app.activate()
      }
    }

    func openAppSwitcher() throws {
      // TODO: Implement for iPhones without notch

      runAction("opening app switcher") {
        let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.999))
        let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.001))
        start.press(forDuration: 0.1, thenDragTo: end)
      }
    }

    func openControlCenter() throws {
      runAction("opening control center") {
        self.swipeToOpenControlCenter()
      }
    }

    // MARK: General UI interaction

    func tap(onText text: String, inApp bundleId: String, atIndex index: Int) throws {
      let view = "view with text \(format: text) at index \(index) in app \(bundleId)"

      try runAction("tapping on \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        // The below selector is an equivalent of `app.descendants(matching: .any)[text]`
        // TODO: We should consider more view properties. See #1554
        let format = """
          label == %@ OR \
          title == %@ OR \
          identifier == %@
          """
        let predicate = NSPredicate(format: format, text, text, text)
        let query = app.descendants(matching: .any).matching(predicate)

        Logger.shared.i("waiting for existence of \(view)")
        guard let element = self.waitFor(query: query, index: index, timeout: self.timeout) else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
      }
    }

    func doubleTap(onText text: String, inApp bundleId: String) throws {
      try runAction("double tapping on text \(format: text) in app \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)
        let element = app.descendants(matching: .any)[text]

        let exists = element.waitForExistence(timeout: self.timeout)
        guard exists else {
          throw PatrolError.viewNotExists(
            "view with text \(format: text) in app \(format: bundleId)")
        }

        element.firstMatch.forceTap()
      }
    }

    func enterText(
      _ data: String,
      byText text: String,
      atIndex index: Int,
      inApp bundleId: String,
      dismissKeyboard: Bool
    ) throws {
      var data = data
      if dismissKeyboard {
        data = "\(data)\n"
      }

      let view = "text field with text \(format: text) at index \(index) in app \(bundleId)"

      try runAction("entering text \(format: data) into \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        // elementType must be specified as integer
        // See:
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypetextfield
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypesecuretextfield
        // The below selector is an equivalent of `app.descendants(matching: .any)[text]`
        // TODO: We should consider more view properties. See #1554
        let format = """
          label == %@ OR \
          title == %@ OR \
          identifier == %@ OR \
          value == %@ OR \
          placeholderValue == %@
          """
        let contentPredicate = NSPredicate(format: format, text, text, text, text, text)
        let textFieldPredicate = NSPredicate(format: "elementType == 49")
        let secureTextFieldPredicate = NSPredicate(format: "elementType == 50")

        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
          contentPredicate,
          NSCompoundPredicate(orPredicateWithSubpredicates: [
            textFieldPredicate, secureTextFieldPredicate,
          ]
          ),
        ])

        let query = app.descendants(matching: .any).matching(finalPredicate)
        guard
          let element = self.waitFor(
            query: query,
            index: index,
            timeout: self.timeout
          )
        else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
        element.typeText(data)
      }

      // Prevent keyboard dismissal from happening too fast
      sleepTask(timeInSeconds: 1)
    }

    func enterText(
      _ data: String,
      byIndex index: Int,
      inApp bundleId: String,
      dismissKeyboard: Bool
    ) throws {
      var data = data
      if dismissKeyboard {
        data = "\(data)\n"
      }

      try runAction("entering text \(format: data) by index \(index) in app \(bundleId)") {
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

        let textFieldsQuery = app.descendants(matching: .any).matching(predicate)
        guard
          let element = self.waitFor(
            query: textFieldsQuery,
            index: index,
            timeout: self.timeout
          )
        else {
          throw PatrolError.viewNotExists("text field at index \(index) in app \(bundleId)")
        }

        element.forceTap()
        element.typeText(data)
      }

      // Prevent keyboard dismissal from happening too fast
      sleepTask(timeInSeconds: 1)
    }

    func swipe(from start: CGVector, to end: CGVector, inApp bundleId: String) throws {
      try runAction("swiping from \(start) to \(end) in app \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)

        let startCoordinate = app.coordinate(
          withNormalizedOffset: CGVector(dx: start.dx, dy: start.dy))
        let endCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: end.dx, dy: end.dy))
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
      }
    }

    func waitUntilVisible(onText text: String, inApp bundleId: String) throws {
      try runAction(
        "waiting until view with text \(format: text) in app \(bundleId) becomes visible"
      ) {
        let app = try self.getApp(withBundleId: bundleId)
        let element = app.descendants(matching: .any)[text]
        let exists = element.waitForExistence(timeout: self.timeout)
        guard exists else {
          throw PatrolError.viewNotExists(
            "view with text \(format: text) in app \(format: bundleId)")
        }
      }
    }

    // MARK: Services

    func enableDarkMode(_ bundleId: String) throws {
      try runSettingsAction("enabling dark mode", bundleId) {
        #if targetEnvironment(simulator)
          self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()

          let value =
            self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value
            as? String?
          if value == "0" {
            self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.tap()
          }
        #else
          self.preferences.descendants(matching: .any)["Display & Brightness"].firstMatch.tap()
          self.preferences.descendants(matching: .any)["Dark"].firstMatch.tap()
        #endif
      }
    }

    func disableDarkMode(_ bundleId: String) throws {
      try runSettingsAction("disabling dark mode", bundleId) {
        #if targetEnvironment(simulator)
          self.preferences.descendants(matching: .any)["Developer"].firstMatch.tap()

          let value =
            self.preferences.descendants(matching: .any)["Dark Appearance"].firstMatch.value
            as? String?
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
          // If SIM card is not available, a dialog appears after disabling airplane mode
          try self.acceptSystemAlertIfVisible()
        } else {
          Logger.shared.i("airplane mode is already disabled")
        }
      }
    }

    func enableCellular() throws {
      try runControlCenterAction("enabling cellular") {
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

    func disableCellular() throws {
      try runControlCenterAction("disabling cellular") {
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

    func enableWiFi() throws {
      try runControlCenterAction("enabling wifi") {
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

    func disableWiFi() throws {
      try runControlCenterAction("disabling wifi") {
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

    func enableBluetooth() throws {
      try runControlCenterAction("enabling bluetooth") {
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

    func disableBluetooth() throws {
      try runControlCenterAction("disabling bluetooth") {
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

    func getNativeViews(
      byText text: String,
      inApp bundleId: String
    ) throws -> [NativeView] {
      try runAction("getting native views matching \(text)") {
        let app = try self.getApp(withBundleId: bundleId)

        // The below selector is an equivalent of `app.descendants(matching: .any)[text]`
        // TODO: We should consider more view properties. See #1554
        let format = """
          label == %@ OR \
          title == %@ OR \
          identifier == %@
          """
        let predicate = NSPredicate(format: format, text, text, text)
        let query = app.descendants(matching: .any).matching(predicate)
        let elements = query.allElementsBoundByIndex

        let views = elements.map { xcuielement in
          return NativeView.fromXCUIElement(xcuielement, bundleId)
        }

        return views
      }
    }

    func getUITreeRoots(installedApps: [String]) throws -> [NativeView] {
      try runAction("getting ui tree roots") {
        let foregroundApp = self.getForegroundApp(installedApps: installedApps)
        let snapshot = try foregroundApp.snapshot()
        return [NativeView.fromXCUIElementSnapshot(snapshot, foregroundApp.identifier)]
      }
    }

    private func getForegroundApp(installedApps: [String]) -> XCUIApplication {
      let app = XCUIApplication()
      if app.state == .runningForeground {
        return app
      } else {
        for bundleIdentifier in installedApps {
          let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
          if app.state == .runningForeground {
            return app
          }
        }
        return self.springboard
      }
    }

    // MARK: Notifications

    func openNotifications() throws {
      // TODO: Check if works on iPhones without notch

      runAction("opening notifications") {
        let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01))
        let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
        start.press(forDuration: 0.1, thenDragTo: end)
      }
    }

    func closeNotifications() throws {
      // TODO: Check if works on iPhones without notch

      runAction("closing notifications") {
        let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
        let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
        start.press(forDuration: 0.1, thenDragTo: end)
      }
    }

    func closeHeadsUpNotification() throws {
      // If the notification was triggered just now, let's wait for it
      sleepTask(timeInSeconds: 2)

      runAction("closing heads up notification") {
        let start = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
        let end = self.springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.07))
        start.press(forDuration: 0.1, thenDragTo: end)
      }

      // We can't open notification shade immediately after dismissing
      // the heads-up notification. Let's wait some reasonable amount of
      // time for it.
      sleepTask(timeInSeconds: 1)
    }

    func getNotifications() throws -> [Notification] {
      var notifications = [Notification]()
      runAction("getting notifications") {
        let cells = self.springboard.buttons.matching(identifier: "NotificationCell")
          .allElementsBoundByIndex
        for (i, cell) in cells.enumerated() {
          Logger.shared.i("found notification at index \(i) with label \(format: cell.label)")
          let notification = Notification(title: String(), content: String(), raw: cell.label)
          notifications.append(notification)
        }
      }

      return notifications
    }

    func tapOnNotification(byIndex index: Int) throws {
      try runAction("tapping on notification at index \(index)") {
        let cells = self.springboard.buttons.matching(identifier: "NotificationCell")
          .allElementsBoundByIndex
        guard cells.indices.contains(index) else {
          throw PatrolError.viewNotExists("notification at index \(index)")
        }

        if self.isSimulator() && self.isPhone() {
          // For some weird reason, this works differently on Simulator
          cells[index].doubleTap()
          self.springboard.buttons.matching(identifier: "Open").firstMatch.tap()
        } else {
          cells[index].tap()
        }
      }
    }

    func tapOnNotification(bySubstring substring: String) throws {
      try runAction("tapping on notification containing text \(format: substring)") {
        let cells = self.springboard.buttons.matching(identifier: "NotificationCell")
          .allElementsBoundByIndex
        for (i, cell) in cells.enumerated() {
          if cell.label.contains(substring) {
            Logger.shared.i(
              "tapping on notification at index \(i) which contains text \(substring)")
            if self.isSimulator() && self.isPhone() {
              // For some weird reason, this works differently on Simulator
              cell.doubleTap()
              self.springboard.buttons.matching(identifier: "Open").firstMatch.tap()
            } else {
              cell.tap()
            }
            return
          }
        }

        throw PatrolError.viewNotExists("notification containing text \(format: substring)")
      }
    }

    // MARK: Permissions

    func isPermissionDialogVisible(timeout: TimeInterval) -> Bool {
      return runAction("checking if permission dialog is visible") {
        let systemAlerts = self.springboard.alerts
        let labels = ["OK", "Allow", "Allow once", "Allow While Using App", "Don’t Allow"]

        let button = self.waitForAnyElement(
          elements: labels.map { systemAlerts.buttons[$0] },
          timeout: timeout
        )

        return button != nil
      }
    }

    func allowPermissionWhileUsingApp() throws {
      try runAction("allowing while using app") {
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

    func allowPermissionOnce() throws {
      try runAction("allowing once") {
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

    func denyPermission() throws {
      try runAction("denying permission") {
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

    func selectFineLocation() throws {
      if iOS13orOlder() {
        Logger.shared.i("Ignored call to selectFineLocation() (iOS < 14)")
        return
      }

      try runAction("selecting fine location") {
        let alerts = self.springboard.alerts
        let button = alerts.buttons["Precise: Off"]

        let exists = button.waitForExistence(timeout: self.timeout)
        guard exists else {
          throw PatrolError.viewNotExists("button to select fine location")
        }

        button.tap()
      }
    }

    func selectCoarseLocation() throws {
      if iOS13orOlder() {
        Logger.shared.i("Ignored call to selectCoarseLocation() (iOS < 14)")
        return
      }

      try runAction("selecting coarse location") {
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

          Logger.shared.i(
            "index: \(i), label: \(label), accLabel: \(String(describing: accLabel)), ident: \(ident)"
          )
        }
      }
    }

    // MARK: Private stuff
    private func isSimulator() -> Bool {
      #if targetEnvironment(simulator)
        return true
      #else
        return false
      #endif
    }

    private func isPhone() -> Bool {
      return UIDevice.current.userInterfaceIdiom == .phone
    }

    /// Based on the list from https://gist.github.com/adamawolf/3048717
    private func isIphone8OrLower() -> Bool {
      var size = 0
      sysctlbyname("hw.machine", nil, &size, nil, 0)
      var machine = [CChar](repeating: 0, count: size)
      sysctlbyname("hw.machine", &machine, &size, nil, 0)
      let model = String(cString: machine)

      return
        model == "iPhone7,1"  // iPhone 6 Plus
        || model == "iPhone7,2"  // iPhone 6
        || model == "iPhone8,1"  // iPhone 6s
        || model == "iPhone8,2"  // iPhone 6s Plus
        || model == "iPhone8,4"  // iPhone SE (GSM)
        || model == "iPhone9,1"  // iPhone 7
        || model == "iPhone9,2"  // iPhone 7 Plus
        || model == "iPhone9,3"  // iPhone 7
        || model == "iPhone9,4"  // iPhone 7 Plus
        || model == "iPhone10,1"  // iPhone 8
        || model == "iPhone10,2"  // iPhone 8 Plus
        || model == "iPhone10,4"  // iPhone 8
        || model == "iPhone10,5"  // iPhone 8 Plus
        || model == "iPhone12,8"  // iPhone SE 2nd Gen
        || model == "iPhone14,6"  // iPhone SE 3rd Gen
    }

    private func iOS13orOlder() -> Bool {
      let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue
      return floatVersion < 14
    }

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

    @discardableResult
    func waitFor(query: XCUIElementQuery, index: Int, timeout: TimeInterval) -> XCUIElement? {
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
      let start: CGVector
      let end: CGVector

      if self.isIphone8OrLower() {
        start = CGVector(dx: 0.5, dy: 0.99)
        end = CGVector(dx: 0.5, dy: 0.8)
      } else {
        start = CGVector(dx: 0.9, dy: 0.01)
        end = CGVector(dx: 0.9, dy: 0.2)
      }

      let startPoint = self.springboard.coordinate(withNormalizedOffset: start)
      let endPoint = self.springboard.coordinate(withNormalizedOffset: end)
      startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
    }

    private func acceptSystemAlertIfVisible() throws {
      let systemAlerts = self.springboard.alerts
      let labels = ["OK"]

      if let button = self.waitForAnyElement(
        elements: labels.map { systemAlerts.buttons[$0] },
        timeout: self.timeout
      ) {
        button.tap()
      }
    }

    private func runControlCenterAction(_ log: String, block: @escaping () throws -> Void) throws {
      #if targetEnvironment(simulator)
        throw PatrolError.internal("Control Center is not available on Simulator")
      #endif

      try runAction(log) {
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
    ) throws {
      try runAction(log) {
        self.springboard.activate()
        self.preferences.launch()  // reset to a known state

        block()

        self.springboard.activate()
        self.preferences.terminate()

        // go back to the app under test
        let app = try self.getApp(withBundleId: bundleId)
        app.activate()
      }
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

    private func sleepTask(timeInSeconds: Double) {
      let group = DispatchGroup()
      group.enter()

      DispatchQueue.global().asyncAfter(deadline: .now() + timeInSeconds) {
        group.leave()
      }

      group.wait()
    }
  }

  // MARK: Utilities

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

  extension NativeView {
    static func fromXCUIElement(_ xcuielement: XCUIElement, _ bundleId: String) -> NativeView {
      return NativeView(
        className: getElementTypeName(elementType: xcuielement.elementType),
        text: xcuielement.label,
        contentDescription: xcuielement.accessibilityLabel,
        focused: xcuielement.hasFocus,
        enabled: xcuielement.isEnabled,
        resourceName: xcuielement.identifier,
        applicationPackage: bundleId,
        children: xcuielement.children(matching: .any).allElementsBoundByIndex.map { child in
          return NativeView.fromXCUIElement(child, bundleId)
        })
    }

    static func fromXCUIElementSnapshot(_ xcuielement: XCUIElementSnapshot, _ bundleId: String)
      -> NativeView
    {
      return NativeView(
        className: getElementTypeName(elementType: xcuielement.elementType),
        text: xcuielement.label,
        contentDescription: "",  // TODO: Separate request
        focused: xcuielement.hasFocus,
        enabled: xcuielement.isEnabled,
        resourceName: xcuielement.identifier,
        applicationPackage: bundleId,
        children: xcuielement.children.map { child in
          return NativeView.fromXCUIElementSnapshot(child, bundleId)
        })
    }
  }

#endif
