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

  extension IOSSelector {
    public func toNSPredicate() -> NSPredicate {
      var values = [Any]()
      var conditions = [String]()

      if let value = value {
        conditions.append("value == %@")
        values.append(value)
      }

      if let iosElementType = elementType {
        let elementTypeValue = getXCUIElementType(elementType: iosElementType).rawValue
        conditions.append("elementType == %@")
        values.append(elementTypeValue)
      }

      if let identifier = identifier {
        conditions.append("identifier == %@")
        values.append(identifier)
      }

      if let label = label {
        conditions.append("label == %@")
        values.append(label)
      }

      if let labelStartsWith = labelStartsWith {
        conditions.append("label BEGINSWITH %@")
        values.append(labelStartsWith)
      }

      if let labelContains = labelContains {
        conditions.append("label CONTAINS %@")
        values.append(labelContains)
      }

      if let title = title {
        conditions.append("title == %@")
        values.append(title)
      }

      if let titleStartsWith = titleStartsWith {
        conditions.append("title BEGINSWITH %@")
        values.append(titleStartsWith)
      }

      if let titleContains = titleContains {
        conditions.append("title CONTAINS %@")
        values.append(titleContains)
      }

      if let hasFocus = hasFocus {
        conditions.append("hasFocus == " + (hasFocus ? "YES" : "NO"))
      }

      if let isEnabled = isEnabled {
        conditions.append("isEnabled == " + (isEnabled ? "YES" : "NO"))
      }

      if let isSelected = isSelected {
        conditions.append("isSelected == " + (isSelected ? "YES" : "NO"))
      }

      if let placeholderValue = placeholderValue {
        conditions.append("placeholderValue == %@")
        values.append(placeholderValue)
      }

      if let placeholderValueStartsWith = placeholderValueStartsWith {
        conditions.append("placeholderValue BEGINSWITH %@")
        values.append(placeholderValueStartsWith)
      }

      if let placeholderValueContains = placeholderValueContains {
        conditions.append("placeholderValue CONTAINS %@")
        values.append(placeholderValueContains)
      }

      let format = conditions.joined(separator: " AND ")

      let predicate = NSPredicate(format: format, argumentArray: values)

      return predicate
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
    func tap(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws
    func tap(
      on selector: IOSSelector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws
    func doubleTap(
      on selector: Selector,
      inApp bundleId: String,
      withTimeout timeout: TimeInterval?
    ) throws
    func doubleTap(
      on selector: IOSSelector,
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
      on selector: IOSSelector,
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
    func waitUntilVisible(
      on selector: IOSSelector,
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
    func getNativeViews(
      on selector: IOSSelector,
      inApp bundleId: String
    ) throws -> [IOSNativeView]
    func getUITreeRoots(installedApps: [String]) throws -> [NativeView]
    func getUITreeRootsV2(installedApps: [String]) throws -> GetNativeUITreeRespone

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
