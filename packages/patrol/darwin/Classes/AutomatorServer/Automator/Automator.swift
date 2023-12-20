#if PATROL_ENABLED
  import XCTest
  import os

  extension Selector {
    func toNSPredicate() -> NSPredicate {
      
      var format = ""
      var begun = false
      let values = [String]()
      
      var text: String?
      var textStartsWith: String?
      var textContains: String?
      
      if (self.text != nil) {
        if (begun) { format += " AND " }
        begun = true
        format += "label == %@ AND title == %@"
        values.append(self.text)
      }
      
      if (self.textStartsWith) {
        if (begun) { format += " AND " }
        begun = true
        format += "label == %@ OR title == %@"
        values.append(self.text)
      }
      
      if (self.textContains) {
        
      }
      
      if (self.resourceId) {
        if (begun) { format += " AND " }
        begun = true
        format += "identifier == %@"
        
      }
      
      
      
      let format = """
        label == %@ OR \
        title == %@ OR \
        identifier == %@
        """
      
      let predicate = NSPredicate(format: format, text, text, text)
      
      
      return predicate;
    }
  }

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
