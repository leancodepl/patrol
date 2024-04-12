#if PATROL_ENABLED && os(iOS)

  import XCTest
  import os

  class IOSAutomator: Automator {
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
    func tap(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws {
      var view = createLogMessage(element: "view", from: selector)
      view += " in app \(bundleId)"

      try runAction("tapping on \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        // TODO: We should consider more view properties. See #1554
        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())

        Logger.shared.i("waiting for existence of \(view)")
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
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

        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())

        Logger.shared.i("waiting for existence of \(view)")
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
      }
    }

    func doubleTap(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws {
      var view = createLogMessage(element: "view", from: selector)
      view += " in app \(bundleId)"

      try runAction("double tapping on \(view)") {
        let app = try self.getApp(withBundleId: bundleId)
        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())

        Logger.shared.i("waiting for existence of \(view)")
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
      }
    }

    func doubleTap(
      on selector: IOSSelector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws {
      var view = createLogMessage(element: "view", from: selector)
      view += " in app \(bundleId)"

      try runAction("double tapping on \(view)") {
        let app = try self.getApp(withBundleId: bundleId)
        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())

        Logger.shared.i("waiting for existence of \(view)")
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
      }
    }

    func tapAt(coordinate vector: CGVector, inApp bundleId: String) throws {
      try runAction("tapping at coordinate \(vector) in app \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)

        let coordinate = app.coordinate(withNormalizedOffset: vector)

        coordinate.tap()
      }
    }

    func enterText(
      _ data: String,
      on selector: Selector,
      inApp bundleId: String,
      dismissKeyboard: Bool,
      withTimeout timeout: TimeInterval?
    ) throws {
      var data = data
      if dismissKeyboard {
        data = "\(data)\n"
      }

      var view = createLogMessage(element: "text field", from: selector)
      view += " in app \(bundleId)"

      try runAction("entering text \(format: data) into \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        // elementType must be specified as integer
        // See:
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypetextfield
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypesecuretextfield
        // TODO: We should consider more view properties. See #1554
        let contentPredicate = selector.toTextFieldNSPredicate()
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
            index: selector.instance ?? 0,
            timeout: timeout ?? self.timeout
          )
        else {
          throw PatrolError.viewNotExists(view)
        }

        self.clearAndEnterText(data: data, element: element)
      }

      // Prevent keyboard dismissal from happening too fast
      sleepTask(timeInSeconds: 1)
    }

    func enterText(
      _ data: String,
      on selector: IOSSelector,
      inApp bundleId: String,
      dismissKeyboard: Bool,
      withTimeout timeout: TimeInterval?
    ) throws {
      var data = data
      if dismissKeyboard {
        data = "\(data)\n"
      }

      var view = createLogMessage(element: "text field", from: selector)
      view += " in app \(bundleId)"

      try runAction("entering text \(format: data) into \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())
        guard
          let element = self.waitFor(
            query: query,
            index: selector.instance ?? 0,
            timeout: timeout ?? self.timeout
          )
        else {
          throw PatrolError.viewNotExists(view)
        }

        self.clearAndEnterText(data: data, element: element)
      }

      // Prevent keyboard dismissal from happening too fast
      sleepTask(timeInSeconds: 1)
    }

    func enterText(
      _ data: String,
      byIndex index: Int,
      inApp bundleId: String,
      dismissKeyboard: Bool,
      withTimeout timeout: TimeInterval?
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
            timeout: timeout ?? self.timeout
          )
        else {
          throw PatrolError.viewNotExists("text field at index \(index) in app \(bundleId)")
        }

        self.clearAndEnterText(data: data, element: element)
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

    func waitUntilVisible(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws {
      let view = createLogMessage(element: "view", from: selector)
      try runAction(
        "waiting until \(view) in app \(bundleId) becomes visible"
      ) {
        let app = try self.getApp(withBundleId: bundleId)
        let query = app.descendants(matching: .any).containing(selector.toNSPredicate())
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
        }
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
        let query = app.descendants(matching: .any).containing(selector.toNSPredicate())
        guard
          let element = self.waitFor(
            query: query, index: selector.instance ?? 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists(view)
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
      on selector: Selector,
      inApp bundleId: String
    ) throws -> [NativeView] {
      let view = createLogMessage(element: "views", from: selector)
      return try runAction("getting native \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        // TODO: We should consider more view properties. See #1554
        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())
        let elements = query.allElementsBoundByIndex

        let views = elements.map { xcuielement in
          return NativeView.fromXCUIElement(xcuielement, bundleId)
        }

        return views
      }
    }

    func getNativeViews(
      on selector: IOSSelector,
      inApp bundleId: String
    ) throws -> [IOSNativeView] {
      let view = createLogMessage(element: "views", from: selector)
      return try runAction("getting native \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        let query = app.descendants(matching: .any).matching(selector.toNSPredicate())
        let elements = query.allElementsBoundByIndex

        let views = elements.map { xcuielement in
          return IOSNativeView.fromXCUIElement(xcuielement, bundleId)
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

    func getUITreeRootsV2(installedApps: [String]) throws -> GetNativeUITreeRespone {
      try runAction("getting ui tree roots") {
        let foregroundApp = self.getForegroundApp(installedApps: installedApps)
        let snapshot = try foregroundApp.snapshot()
        let root = IOSNativeView.fromXCUIElementSnapshot(snapshot, foregroundApp.identifier)
        return GetNativeUITreeRespone(iOSroots: [root], androidRoots: [], roots: [])
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

    func tapOnNotification(byIndex index: Int, withTimeout timeout: TimeInterval?) throws {
      try runAction("tapping on notification at index \(index)") {
        let cellsQuery = self.springboard.buttons.matching(identifier: "NotificationCell")
        guard
          let cell = self.waitFor(query: cellsQuery, index: index, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists("notification at index \(index)")
        }

        if self.isSimulator() && self.isPhone() {
          // For some weird reason, this works differently on Simulator
          cell.doubleTap()
          self.springboard.buttons.matching(identifier: "Open").firstMatch.tap()
        } else {
          cell.tap()
        }
      }
    }

    func tapOnNotification(bySubstring substring: String, withTimeout timeout: TimeInterval?) throws
    {
      try runAction("tapping on notification containing text \(format: substring)") {
        let cellsQuery = self.springboard.buttons.matching(
          NSPredicate(
            format: "identifier == %@ AND label CONTAINS %@", "NotificationCell", substring)
        )

        guard let cell = self.waitFor(query: cellsQuery, index: 0, timeout: timeout ?? self.timeout)
        else {
          throw PatrolError.viewNotExists("notification containing text \(format: substring)")
        }
        Logger.shared.i("tapping on notification which contains text \(substring)")
        if self.isSimulator() && self.isPhone() {
          // For some weird reason, this works differently on Simulator
          cell.doubleTap()
          self.springboard.buttons.matching(identifier: "Open").firstMatch.tap()
        } else {
          cell.tap()
        }
      }
    }

    // MARK: Permissions

    func isPermissionDialogVisible(timeout: TimeInterval) throws -> Bool {
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
          throw PatrolError.viewNotExists("button to allow permission while using app")
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
    private func clearAndEnterText(data: String, element: XCUIElement) {
      let currentValue = element.value as? String
      var delete: String = ""
      if let value = currentValue {
        delete = String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)
      }

      // We need to tap at the end of the field to ensure the cursor is at the end
      let coordinate = element.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
      coordinate.tap()

      element.typeText(delete + data)
    }

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

    func createLogMessage(element: String, from selector: Selector) -> String {
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
      if let index = selector.instance {
        logMessage += " at index \(index)"
      }

      return logMessage
    }

    func createLogMessage(element: String, from selector: IOSSelector) -> String {
      var logMessage = element

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
      if let labelStartsWith = selector.labelStartsWith {
        logMessage += " with labelStartsWith '\(labelStartsWith)'"
      }
      if let labelContains = selector.labelContains {
        logMessage += " with labelContains '\(labelContains)'"
      }
      if let title = selector.title {
        logMessage += " with title '\(title)'"
      }
      if let titleStartsWith = selector.titleStartsWith {
        logMessage += " with titleStartsWith '\(titleStartsWith)'"
      }
      if let titleContains = selector.titleContains {
        logMessage += " with titleContains '\(titleContains)'"
      }
      if let hasFocus = selector.hasFocus {
        logMessage += " with hasFocus '\(hasFocus)'"
      }
      if let isEnabled = selector.isEnabled {
        logMessage += " with isEnabled '\(isEnabled)'"
      }
      if let isSelected = selector.isSelected {
        logMessage += " with isSelected '\(isSelected)'"
      }
      if let placeholderValue = selector.placeholderValue {
        logMessage += " with placeholderValue '\(placeholderValue)'"
      }
      if let placeholderValueStartsWith = selector.placeholderValueStartsWith {
        logMessage += " with placeholderValueStartsWith '\(placeholderValueStartsWith)'"
      }
      if let placeholderValueContains = selector.placeholderValueContains {
        logMessage += " with placeholderValueContains '\(placeholderValueContains)'"
      }

      return logMessage
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

  extension IOSNativeView {
    static func fromXCUIElement(_ xcuielement: XCUIElement, _ bundleId: String) -> IOSNativeView {
      return IOSNativeView(
        children: xcuielement.children(matching: .any).allElementsBoundByIndex.map { child in
          return IOSNativeView.fromXCUIElement(child, bundleId)
        },
        elementType: getIOSElementType(elementType: xcuielement.elementType),
        identifier: xcuielement.identifier,
        label: xcuielement.label,
        title: xcuielement.title,
        hasFocus: xcuielement.hasFocus,
        isEnabled: xcuielement.isEnabled,
        isSelected: xcuielement.isSelected,
        frame: Rectangle(
          minX: xcuielement.frame.minX,
          minY: xcuielement.frame.minY,
          maxX: xcuielement.frame.maxX,
          maxY: xcuielement.frame.maxY
        ),
        placeholderValue: xcuielement.placeholderValue,
        value: xcuielement.value as? String
      )
    }
  }

  extension IOSNativeView {
    static func fromXCUIElementSnapshot(_ xcuielement: XCUIElementSnapshot, _ bundleId: String)
      -> IOSNativeView
    {
      return IOSNativeView(
        children: xcuielement.children.map { child in
          return IOSNativeView.fromXCUIElementSnapshot(child, bundleId)
        },
        elementType: getIOSElementType(elementType: xcuielement.elementType),
        identifier: xcuielement.identifier,
        label: xcuielement.label,
        title: xcuielement.title,
        hasFocus: xcuielement.hasFocus,
        isEnabled: xcuielement.isEnabled,
        isSelected: xcuielement.isSelected,
        frame: Rectangle(
          minX: xcuielement.frame.minX,
          minY: xcuielement.frame.minY,
          maxX: xcuielement.frame.maxX,
          maxY: xcuielement.frame.maxY
        ),
        placeholderValue: xcuielement.placeholderValue,
        value: xcuielement.value as? String
      )
    }
  }
#endif
