#if PATROL_ENABLED
  import XCTest
  import os

  protocol Automator {
    func configure(timeout: TimeInterval)
    func pressHome() throws
    func openApp(_ bundleId: String) throws
    func openAppSwitcher() throws
    func openControlCenter() throws
    func tap(onText text: String, inApp bundleId: String, atIndex index: Int) throws
    func doubleTap(onText text: String, inApp bundleId: String) throws
    func enterText(
      _ data: String, byText text: String,
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
    func swipe(from start: CGVector, to end: CGVector, inApp bundleId: String)
    func waitUntilVisible(onText text: String, inApp bundleId: String) throws
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
    func openNotifications() throws
    func closeNotifications() throws
    func closeHeadsUpNotification() throws
    func getNotifications() throws -> [Notification]
    func tapOnNotification(byIndex index: Int) throws
    func tapOnNotification(bySubstring substring: String) throws
    func isPermissionDialogVisible(timeout: TimeInterval) -> Bool 
    func allowPermissionWhileUsingApp() throws 
    func allowPermissionOnce() throws
    func denyPermission() throws
    func selectFineLocation() throws
    func selectCoarseLocation() throws
    func debug() throws
    /// Adapted from https://stackoverflow.com/q/47880395/7009800
    @discardableResult
    func waitForAnyElement(elements: [XCUIElement], timeout: TimeInterval) -> XCUIElement?
    @discardableResult
    func waitFor(query: XCUIElementQuery, index: Int, timeout: TimeInterval) -> XCUIElement?
  }

#endif
