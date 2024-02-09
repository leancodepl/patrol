extension Selector {
  public func toTextFieldNSPredicate() -> NSPredicate {
    var format = ""
    var begun = false
    var values = [String]()

    if text != nil {
      begun = true
      format += "(label == %@ OR title == %@ OR value == %@ OR placeholderValue == %@)"
      values.append(text!)
      values.append(text!)
      values.append(text!)
      values.append(text!)
    }

    if textStartsWith != nil {
      if begun { format += " AND " }
      begun = true
      format +=
        "(label BEGINSWITH %@ OR title BEGINSWITH %@ OR value BEGINSWITH %@ OR placeholderValue BEGINSWITH %@)"
      values.append(textStartsWith!)
      values.append(textStartsWith!)
      values.append(textStartsWith!)
      values.append(textStartsWith!)
    }

    if textContains != nil {
      if begun { format += " AND " }
      begun = true
      format +=
        "(label CONTAINS %@ OR title CONTAINS %@ OR value CONTAINS %@ OR placeholderValue CONTAINS %@)"
      values.append(textContains!)
      values.append(textContains!)
      values.append(textContains!)
      values.append(textContains!)
    }

    if resourceId != nil {
      if begun { format += " AND " }
      begun = true
      format += "(identifier == %@)"
      values.append(resourceId!)
    }

    let predicate = NSPredicate(format: format, argumentArray: values)

    return predicate
  }

  public func toNSPredicate() -> NSPredicate {
    var format = ""
    var begun = false
    var values = [String]()

    if text != nil {
      begun = true
      format += "(label == %@ OR title == %@)"
      values.append(text!)
      values.append(text!)
    }

    if textStartsWith != nil {
      if begun { format += " AND " }
      begun = true
      format += "(label BEGINSWITH %@ OR title BEGINSWITH %@)"
      values.append(textStartsWith!)
      values.append(textStartsWith!)
    }

    if textContains != nil {
      if begun { format += " AND " }
      begun = true
      format += "(label CONTAINS %@ OR title CONTAINS %@)"
      values.append(textContains!)
      values.append(textContains!)
    }

    if resourceId != nil {
      if begun { format += " AND " }
      begun = true
      format += "(identifier == %@)"
      values.append(resourceId!)
    }

    let predicate = NSPredicate(format: format, argumentArray: values)

    return predicate
  }
}

#if PATROL_ENABLED
  import XCTest
  import os

  protocol Automator {
    func configure(timeout: TimeInterval)

    // MARK: General
    func pressHome() throws
    func openApp(_ bundleId: String) throws
    func openAppSwitcher() throws
    func openControlCenter() throws

    // MARK: General UI interaction
    func tap(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws
    func doubleTap(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws
    func tapAt(coordinate vector: CGVector, inApp bundleId: String) throws
    func enterText(
      _ data: String,
      on selector: Selector,
      inApp bundleId: String,
      dismissKeyboard: Bool,
      withTimeout timeout: TimeInterval?
    ) throws
    func enterText(
      _ data: String,
      byIndex index: Int,
      inApp bundleId: String,
      dismissKeyboard: Bool,
      withTimeout timeout: TimeInterval?
    ) throws
    func swipe(from start: CGVector, to end: CGVector, inApp bundleId: String) throws
    func waitUntilVisible(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws

    // MARK: Services
    func enableDarkMode(_ bundleId: String) throws
    func disableDarkMode(_ bundleId: String) throws
    func enableAirplaneMode() throws
    func disableAirplaneMode() throws
    func enableCellular() throws
    func disableCellular() throws
    func enableWiFi() throws
    func disableWiFi() throws
    func enableBluetooth() throws
    func disableBluetooth() throws
    func getNativeViews(
      on selector: Selector,
      inApp bundleId: String
    ) throws -> [NativeView]
    func getUITreeRoots(installedApps: [String]) throws -> [NativeView]

    // MARK: Notifications
    func openNotifications() throws
    func closeNotifications() throws
    func closeHeadsUpNotification() throws
    func getNotifications() throws -> [Notification]
    func tapOnNotification(byIndex index: Int, withTimeout timeout: TimeInterval?) throws
    func tapOnNotification(bySubstring substring: String, withTimeout timeout: TimeInterval?) throws

    // MARK: Permissions
    func isPermissionDialogVisible(timeout: TimeInterval) throws -> Bool
    func allowPermissionWhileUsingApp() throws
    func allowPermissionOnce() throws
    func denyPermission() throws
    func selectFineLocation() throws
    func selectCoarseLocation() throws

    // MARK: Other
    func debug() throws
  }

#endif
