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
      onText text: String,
      inApp bundleId: String,
      atIndex index: Int,
      withTimeout timeout: TimeInterval?
    ) throws
    func doubleTap(
      onText text: String,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws
    func enterText(
      _ data: String,
      byText text: String,
      atIndex index: Int,
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
      onText text: String,
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
      byText text: String,
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
