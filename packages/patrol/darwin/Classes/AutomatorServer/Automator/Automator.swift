public extension Selector {
  func toNSPredicate() -> NSPredicate {
    var format = ""
    var begun = false
    var values = [String]()
    
    if (text != nil) {
      begun = true
      format += "(label == %@ OR title == %@)"
      values.append(text!)
      values.append(text!)
    }
    
    if (textStartsWith != nil) {
      if (begun) { format += " AND " }
      begun = true
      format += "(label BEGINSWITH %@ OR title BEGINSWITH %@)"
      values.append(textStartsWith!)
      values.append(textStartsWith!)
    }
    
    if (textContains != nil) {
      if (begun) { format += " AND " }
      begun = true
      format += "(label CONTAINS %@ OR title CONTAINS %@)"
      values.append(textContains!)
      values.append(textContains!)
    }
    
    if (resourceId != nil) {
      if (begun) { format += " AND " }
      begun = true
      format += "(identifier == %@)"
      values.append(resourceId!)
    }
    
    let predicate = NSPredicate(format: format, argumentArray: values)
    
    return predicate;
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
    func tap(_ selector: Selector) throws
    func doubleTap(onText text: String, inApp bundleId: String) throws
    func enterText(
      _ data: String,
      byText text: String,
      atIndex index: Int,
      inApp bundleId: String,
      dismissKeyboard: Bool
    ) throws
    func enterText(
      _ data: String,
      byIndex index: Int,
      inApp bundleId: String,
      dismissKeyboard: Bool
    ) throws
    func swipe(from start: CGVector, to end: CGVector, inApp bundleId: String) throws
    func waitUntilVisible(onText text: String, inApp bundleId: String) throws

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
      byText text: String,
      inApp bundleId: String
    ) throws -> [NativeView]
    func getUITreeRoots(installedApps: [String]) throws -> [NativeView]

    // MARK: Notifications
    func openNotifications() throws
    func closeNotifications() throws
    func closeHeadsUpNotification() throws
    func getNotifications() throws -> [Notification]
    func tapOnNotification(byIndex index: Int) throws
    func tapOnNotification(bySubstring substring: String) throws

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
